#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
sound_bodyfollower_node: 语音驱动的人体跟踪节点。
订阅 /command (std_msgs/String) — JSON 指令数组。
筛选 actuator="底盘"、action="人体跟踪"、params 含 "开始" 的指令。

启动时直接拉起完整的 bodyfollow.launch.py（相机 + body tracking 全开）。
收到语音指令后切换 follower 的 mode（1:sleep → 2:follow），跟随立即生效。
"""
import json
import os
import queue
import signal
import subprocess
import threading
import time

import rclpy
from rclpy.node import Node
from std_msgs.msg import String, Int8


def _clean_env():
    """复制当前环境，清理 LD_LIBRARY_PATH 中的 /lib。"""
    env = os.environ.copy()
    if "LD_LIBRARY_PATH" in env:
        paths = [p for p in env["LD_LIBRARY_PATH"].split(":") if p and p != "/lib"]
        env["LD_LIBRARY_PATH"] = ":".join(paths)
    return env


class SoundBodyFollower(Node):
    def __init__(self):
        super().__init__("sound_bodyfollower")
        self.create_subscription(String, "/command", self._on_command, 10)

        # 发布 mode 切换指令（1:sleep → 2:follow）
        self._mode_pub = self.create_publisher(Int8, "/mode", 10)

        self._work_q     = queue.Queue()
        self._process    = None
        self._lock       = threading.Lock()
        self._following  = False

        threading.Thread(target=self._work_loop,   daemon=True).start()
        threading.Thread(target=self._status_loop, daemon=True).start()

        # ── 启动时立即拉起完整的 bodyfollow ──
        self._start_bodyfollow()

    def _start_bodyfollow(self):
        env = _clean_env()
        self.get_logger().info("▶ 启动 bodyfollow (相机 + body tracking 全开，语音静默)")
        self._process = subprocess.Popen(
            ["ros2", "launch", "bodyreader", "bodyfollow.launch.py",
             "voice_feedback:=false"],
            env=env,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            preexec_fn=lambda: signal.signal(signal.SIGINT, signal.SIG_IGN),
        )
        # 等节点启动后：关掉语音反馈 + 发 mode=1 让 follower 休眠
        threading.Timer(5.0, self._init_after_launch).start()

    def _init_after_launch(self):
        # 关闭 feedback 语音
        subprocess.Popen(
            ["ros2", "param", "set", "/body_feedback", "voice_feedback", "false"],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
        self.get_logger().info("已关闭 feedback 语音")
        # follower 进入待命
        msg = Int8()
        msg.data = 1
        self._mode_pub.publish(msg)
        self.get_logger().info("已发送 mode=1，follower 进入待命")

    def _on_command(self, msg: String):
        self._work_q.put(msg.data)

    def _work_loop(self):
        while rclpy.ok():
            cmd_json = self._work_q.get()
            try:
                commands = json.loads(cmd_json)
                if not isinstance(commands, list):
                    continue
                for cmd in commands:
                    actuator = cmd.get("actuator", "")
                    action   = cmd.get("action", "")
                    params   = cmd.get("params", {})
                    if actuator == "底盘" and action == "人体跟踪" and "开始" in params:
                        self._start_follow()
            except json.JSONDecodeError:
                self.get_logger().error(f"JSON 解析失败: {cmd_json}")
            except Exception as e:
                self.get_logger().error(f"处理异常: {e}")

    def _start_follow(self):
        """切换 mode 到 2（follow），开启语音反馈，跟随立即生效。"""
        with self._lock:
            if self._following:
                self.get_logger().info("已在跟随中，忽略重复指令")
                return
            self.get_logger().info("▶ 切换到跟随模式 (mode=2)")
            # 开启 feedback 语音
            subprocess.Popen(
                ["ros2", "param", "set", "/body_feedback", "voice_feedback", "true"],
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
            )
            msg = Int8()
            msg.data = 2
            self._mode_pub.publish(msg)
            self._following = True

    def _status_loop(self):
        while rclpy.ok():
            with self._lock:
                alive = self._process is not None and self._process.poll() is None
            if alive:
                status = "跟随中 ✓" if self._following else "待命（相机已就绪）"
                self.get_logger().info(f"状态: {status}")
            elif self._following:
                self.get_logger().warn("状态: bodyfollow 进程已退出")
                self._following = False
            else:
                self.get_logger().info("状态: 未启动")
            time.sleep(10.0)

    def _stop_follow(self):
        with self._lock:
            self._following = False
            # 发 mode=1 切回 sleep
            msg = Int8()
            msg.data = 1
            self._mode_pub.publish(msg)
            self.get_logger().info("■ 已切换到待命模式 (mode=1)")

    def destroy_node(self):
        self._stop_follow()
        if self._process and self._process.poll() is None:
            self._process.terminate()
        super().destroy_node()


def main():
    rclpy.init()
    node = SoundBodyFollower()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
    rclpy.shutdown()


if __name__ == "__main__":
    main()

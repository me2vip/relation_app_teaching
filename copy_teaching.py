# -*- coding: utf-8 -*-
"""
教学关卡内容复制脚本

从源项目 relation_app 中提取"教学关卡"相关的 Dart 源文件，原样复制到
当前 Flutter 项目（relation_app_teaching）中，保持目录结构一致，不做任何
内容修改。

教学关卡系统由以下 5 个文件构成（位于
lib/features/floating_window/widgets/social_guide/）：
  - teaching_level_system.dart      分级关卡系统（10 级 3 阶）
  - teaching_dialogue_widget.dart   逐步模拟教学对话界面
  - social_knowledge_base.dart      社交知识体系浏览
  - teaching_level_entry_widget.dart 教学入口页面
  - quick_practice_widget.dart      快速练习（入口页依赖）

用法：
    python copy_teaching.py
    python copy_teaching.py --source <源目录> --target <目标目录>
"""

import argparse
import filecmp
import shutil
import sys
from pathlib import Path

# 教学关卡相关源文件（相对路径，源/目标两侧保持一致）
TEACHING_FILES = [
    "lib/features/floating_window/widgets/social_guide/teaching_level_system.dart",
    "lib/features/floating_window/widgets/social_guide/teaching_dialogue_widget.dart",
    "lib/features/floating_window/widgets/social_guide/social_knowledge_base.dart",
    "lib/features/floating_window/widgets/social_guide/teaching_level_entry_widget.dart",
    "lib/features/floating_window/widgets/social_guide/quick_practice_widget.dart",
]

# 默认源/目标目录
DEFAULT_SOURCE = r"p:\ASUS\Desktop\relation_app"
DEFAULT_TARGET = r"p:\ASUS\Desktop\relation_app_teaching"


def copy_file_verbatim(src: Path, dst: Path) -> bool:
    """原样复制单个文件，保持内容字节级一致。

    Returns:
        True 表示发生复制；False 表示目标已与源一致而跳过。
    """
    if not src.is_file():
        raise FileNotFoundError(f"源文件不存在：{src}")

    dst.parent.mkdir(parents=True, exist_ok=True)

    # 已存在且内容一致则跳过，避免无意义的写入
    if dst.is_file() and filecmp.cmp(src, dst, shallow=False):
        return False

    shutil.copyfile(src, dst)
    return True


def main() -> int:
    parser = argparse.ArgumentParser(
        description="从 relation_app 原样复制教学关卡内容到当前项目"
    )
    parser.add_argument("--source", default=DEFAULT_SOURCE,
                        help=f"源项目根目录（默认：{DEFAULT_SOURCE}）")
    parser.add_argument("--target", default=DEFAULT_TARGET,
                        help=f"目标项目根目录（默认：{DEFAULT_TARGET}）")
    parser.add_argument("--force", action="store_true",
                        help="即使目标文件内容一致也强制覆盖")
    args = parser.parse_args()

    source_root = Path(args.source)
    target_root = Path(args.target)

    if not source_root.is_dir():
        print(f"[错误] 源目录不存在：{source_root}", file=sys.stderr)
        return 1
    if not target_root.is_dir():
        print(f"[错误] 目标目录不存在：{target_root}", file=sys.stderr)
        return 1

    print("=" * 70)
    print("教学关卡内容复制脚本")
    print("=" * 70)
    print(f"源目录 : {source_root}")
    print(f"目标目录: {target_root}")
    print("-" * 70)

    copied = 0
    skipped = 0
    failed = 0

    for rel in TEACHING_FILES:
        src = source_root / rel
        dst = target_root / rel
        try:
            if args.force:
                dst.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(src, dst)
                print(f"[复制] {rel}")
                copied += 1
            else:
                done = copy_file_verbatim(src, dst)
                if done:
                    print(f"[复制] {rel}")
                    copied += 1
                else:
                    print(f"[跳过] {rel}  (内容已一致)")
                    skipped += 1
        except FileNotFoundError as e:
            print(f"[缺失] {rel}  -> {e}", file=sys.stderr)
            failed += 1
        except Exception as e:  # noqa: BLE001
            print(f"[失败] {rel}  -> {e}", file=sys.stderr)
            failed += 1

    print("-" * 70)
    print(f"完成：复制 {copied}，跳过 {skipped}，失败 {failed}")
    print("说明：所有文件均按原始内容字节级复制，未做任何修改。")
    print("适配层（main.dart / pubspec.yaml / 主题与工具桩文件）需另行配置。")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())

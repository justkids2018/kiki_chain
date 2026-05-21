#!/usr/bin/env python3
"""
使用微软 Azure TTS 为场景词条生成音频文件
"""
import json
import os
import sys
from pathlib import Path

try:
    import azure.cognitiveservices.speech as speechsdk
except ImportError:
    print("请先安装 Azure Speech SDK: pip install azure-cognitiveservices-speech")
    sys.exit(1)


class AudioGenerator:
    def __init__(self, subscription_key: str, region: str):
        """
        初始化 Azure TTS 客户端

        Args:
            subscription_key: Azure Speech 服务的订阅密钥
            region: Azure 区域，如 'eastasia', 'southeastasia' 等
        """
        self.speech_config = speechsdk.SpeechConfig(
            subscription=subscription_key,
            region=region
        )

        # 设置中文语音（女声，自然）
        self.chinese_voice = "zh-CN-XiaoxiaoNeural"

        # 设置英文语音（女声，自然）
        self.english_voice = "en-US-JennyNeural"

    def generate_audio(self, text: str, output_file: str, language: str = "zh-CN"):
        """
        生成单个音频文件

        Args:
            text: 要转换的文本
            output_file: 输出文件路径
            language: 语言类型 'zh-CN' 或 'en-US'
        """
        # 设置音频输出
        audio_config = speechsdk.audio.AudioOutputConfig(filename=output_file)

        # 根据语言选择语音
        if language == "zh-CN":
            self.speech_config.speech_synthesis_voice_name = self.chinese_voice
        else:
            self.speech_config.speech_synthesis_voice_name = self.english_voice

        # 创建合成器
        synthesizer = speechsdk.SpeechSynthesizer(
            speech_config=self.speech_config,
            audio_config=audio_config
        )

        # 合成语音
        result = synthesizer.speak_text_async(text).get()

        if result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted:
            print(f"✓ 生成成功: {output_file}")
            return True
        elif result.reason == speechsdk.ResultReason.Canceled:
            cancellation = result.cancellation_details
            print(f"✗ 生成失败: {cancellation.reason}")
            if cancellation.reason == speechsdk.CancellationReason.Error:
                print(f"  错误详情: {cancellation.error_details}")
            return False

        return False

    def process_scene_json(self, json_file: str, output_dir: str = None):
        """
        处理场景 JSON 文件，为每个词条生成音频

        Args:
            json_file: JSON 文件路径
            output_dir: 输出目录，默认为 JSON 文件所在目录的 audio 子目录
        """
        # 读取 JSON
        with open(json_file, 'r', encoding='utf-8') as f:
            data = json.load(f)

        # 确定输出目录
        if output_dir is None:
            json_path = Path(json_file)
            output_dir = json_path.parent / "audio"

        output_path = Path(output_dir)
        output_path.mkdir(parents=True, exist_ok=True)

        print(f"\n开始处理: {json_file}")
        print(f"输出目录: {output_dir}")
        print(f"词条数量: {len(data)}\n")

        success_count = 0
        fail_count = 0

        # 处理每个词条
        for item in data:
            item_id = item.get('id', 'unknown')
            index = item.get('index', 0)

            # 中文文本
            chinese_text = item.get('text', '')
            chinese_pinyin = item.get('text_pinyin', '')

            # 英文文本
            english_text = item.get('text_english', '')

            print(f"[{index}] {chinese_text} ({chinese_pinyin}) - {english_text}")

            # 生成中文音频
            chinese_file = output_path / f"{item_id}_chinese.mp3"
            if self.generate_audio(chinese_text, str(chinese_file), "zh-CN"):
                success_count += 1
            else:
                fail_count += 1

            # 生成英文音频
            english_file = output_path / f"{item_id}_english.mp3"
            if self.generate_audio(english_text, str(english_file), "en-US"):
                success_count += 1
            else:
                fail_count += 1

            print()

        print(f"\n完成！成功: {success_count}, 失败: {fail_count}")
        return success_count, fail_count


def main():
    # 从环境变量读取配置
    subscription_key = os.environ.get('AZURE_SPEECH_KEY')
    region = os.environ.get('AZURE_SPEECH_REGION', 'eastasia')

    if not subscription_key:
        print("错误: 请设置环境变量 AZURE_SPEECH_KEY")
        print("\n使用方法:")
        print("  export AZURE_SPEECH_KEY='your-key-here'")
        print("  export AZURE_SPEECH_REGION='eastasia'  # 可选，默认 eastasia")
        print("  python generate_audio.py <json_file>")
        sys.exit(1)

    if len(sys.argv) < 2:
        print("使用方法: python generate_audio.py <json_file> [output_dir]")
        sys.exit(1)

    json_file = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else None

    if not os.path.exists(json_file):
        print(f"错误: 文件不存在: {json_file}")
        sys.exit(1)

    # 创建生成器并处理
    generator = AudioGenerator(subscription_key, region)
    generator.process_scene_json(json_file, output_dir)


if __name__ == "__main__":
    main()

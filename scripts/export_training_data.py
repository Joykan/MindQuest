#!/usr/bin/env python3
"""
Training Data Export Script for MindQuest
"""

import json
import requests
import os
from datetime import datetime, timedelta
from pathlib import Path
import argparse


class TrainingDataExporter:
    def __init__(self, api_url):
        self.api_url = api_url.rstrip('/')
        self.output_dir = Path('data/training')
        self.output_dir.mkdir(parents=True, exist_ok=True)
    
    def export_raw_data(self, start_date, end_date, output_file=None):
        """Export raw training data from API"""
        if output_file is None:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            output_file = self.output_dir / f'training_raw_{timestamp}.jsonl'
        
        print(f"📥 Exporting data from {start_date} to {end_date}...")
        
        try:
            response = requests.post(
                f"{self.api_url}/walker/api_export_training_data",
                json={
                    "start_date": start_date,
                    "end_date": end_date,
                    "format": "jsonl"
                },
                timeout=30
            )
            response.raise_for_status()
            data = response.json()
            
            with open(output_file, 'w') as f:
                for record in data.get('data', []):
                    f.write(json.dumps(record) + '\n')
            
            total_records = data.get('total_records', 0)
            print(f"✅ Exported {total_records} records to {output_file}")
            
            return output_file, total_records
            
        except requests.exceptions.RequestException as e:
            print(f"❌ Error exporting data: {e}")
            return None, 0
    
    def prepare_for_fine_tuning(self, input_file, output_file=None):
        """Convert raw data to format suitable for model fine-tuning"""
        if output_file is None:
            output_file = input_file.parent / input_file.name.replace('raw', 'prepared')
        
        print(f"🔄 Preparing data for fine-tuning...")
        
        training_examples = []
        stats = {
            'total': 0,
            'mood_logs': 0,
            'support_requests': 0,
            'journal_entries': 0,
            'insights': 0
        }
        
        with open(input_file, 'r') as f:
            for line in f:
                record = json.loads(line)
                stats['total'] += 1
                
                example = self._create_training_example(record)
                if example:
                    training_examples.append(example)
                    
                    interaction_type = record.get('interaction_type', '')
                    if 'mood' in interaction_type:
                        stats['mood_logs'] += 1
                    elif 'support' in interaction_type:
                        stats['support_requests'] += 1
                    elif 'journal' in interaction_type:
                        stats['journal_entries'] += 1
                    elif 'insight' in interaction_type:
                        stats['insights'] += 1
        
        with open(output_file, 'w') as f:
            for example in training_examples:
                f.write(json.dumps(example) + '\n')
        
        print(f"✅ Prepared {len(training_examples)} training examples")
        print(f"📊 Statistics:")
        for key, value in stats.items():
            print(f"   {key}: {value}")
        
        return output_file, training_examples
    
    def _create_training_example(self, record):
        """Create a training example from a raw record"""
        interaction_type = record.get('interaction_type', '')
        features = record.get('features', {})
        
        if 'mood' in interaction_type or 'log_mood' in interaction_type:
            emotion = features.get('emotion', 'unknown')
            intensity = features.get('intensity_level', 'medium')
            
            return {
                "prompt": f"User is feeling {emotion} with {intensity} intensity.",
                "completion": self._generate_empathetic_response(emotion, intensity),
                "metadata": {
                    "type": "mood_response",
                    "emotion": emotion,
                    "intensity": intensity
                }
            }
        
        elif 'support' in interaction_type or 'suggestion' in interaction_type:
            emotion = features.get('emotion', 'stressed')
            
            return {
                "prompt": f"User needs support for feeling {emotion}. Suggest coping strategies.",
                "completion": self._generate_coping_strategies(emotion),
                "metadata": {
                    "type": "support_request",
                    "emotion": emotion
                }
            }
        
        elif 'pattern' in interaction_type or 'insight' in interaction_type:
            return {
                "prompt": "Analyze user's emotional patterns over time.",
                "completion": self._generate_pattern_insight(),
                "metadata": {
                    "type": "pattern_analysis"
                }
            }
        
        return None
    
    def _generate_empathetic_response(self, emotion, intensity):
        """Generate empathetic response template"""
        responses = {
            'happy': "I'm glad you're feeling happy! It's wonderful to recognize and appreciate these positive moments.",
            'sad': "I hear you. Feeling sad can be tough. Remember that it's okay to feel this way, and these feelings will pass.",
            'anxious': "I understand anxiety can be overwhelming. Let's take this one step at a time. Have you tried some breathing exercises?",
            'angry': "It's valid to feel angry. Let's work on channeling this energy constructively.",
            'calm': "That's wonderful! Moments of calm are precious. What helped you feel this way?",
            'excited': "Your excitement is contagious! It's great to feel energized and enthusiastic."
        }
        
        return responses.get(emotion, "I hear you. Your feelings are valid.")
    
    def _generate_coping_strategies(self, emotion):
        """Generate coping strategies"""
        strategies = {
            'anxious': "Try the 4-7-8 breathing technique: breathe in for 4 seconds, hold for 7, exhale for 8. Also consider a short walk or journaling your thoughts.",
            'sad': "Consider reaching out to a friend, engaging in a comforting activity, or practicing self-compassion. Gentle movement like yoga can also help.",
            'angry': "Physical activity can help release tension. Try a quick workout, deep breathing, or writing down what's bothering you.",
            'stressed': "Break tasks into smaller steps, practice mindfulness, or take a short break to reset."
        }
        
        return strategies.get(emotion, "Focus on self-care activities that you enjoy. Take breaks when needed.")
    
    def _generate_pattern_insight(self):
        """Generate pattern insight template"""
        return "Based on your entries, I notice patterns in your emotional states. Consider what activities or situations tend to influence your mood positively."
    
    def get_training_stats(self):
        """Get training data statistics from API"""
        try:
            response = requests.post(
                f"{self.api_url}/walker/api_training_stats",
                json={},
                timeout=30
            )
            response.raise_for_status()
            stats = response.json()
            
            print("\n📊 Training Data Statistics:")
            print(f"   Total records: {stats.get('total_records', 0)}")
            print(f"   Success rate: {stats.get('success_rate', 0):.2%}")
            print(f"   Ready for training: {stats.get('ready_for_training', False)}")
            
            print("\n   Interaction types:")
            for itype, count in stats.get('interaction_types', {}).items():
                print(f"      {itype}: {count}")
            
            print("\n   Emotion distribution:")
            for emotion, count in stats.get('emotions_distribution', {}).items():
                print(f"      {emotion}: {count}")
            
            return stats
            
        except requests.exceptions.RequestException as e:
            print(f"❌ Error fetching stats: {e}")
            return None


def main():
    parser = argparse.ArgumentParser(description='Export MindQuest training data')
    parser.add_argument('--api-url', default=os.getenv('API_URL', 'http://localhost:8000'),
                      help='API URL')
    parser.add_argument('--days', type=int, default=30,
                      help='Number of days to export (default: 30)')
    parser.add_argument('--stats-only', action='store_true',
                      help='Only show statistics without exporting')
    
    args = parser.parse_args()
    
    exporter = TrainingDataExporter(args.api_url)
    
    if args.stats_only:
        exporter.get_training_stats()
        return
    
    print(f"🚀 MindQuest Training Data Export")
    print(f"API URL: {args.api_url}")
    print(f"Days to export: {args.days}\n")
    
    end_date = datetime.now().isoformat()
    start_date = (datetime.now() - timedelta(days=args.days)).isoformat()
    
    exporter.get_training_stats()
    print()
    
    raw_file, record_count = exporter.export_raw_data(start_date, end_date)
    
    if raw_file and record_count > 0:
        prepared_file, examples = exporter.prepare_for_fine_tuning(raw_file)
        
        if prepared_file:
            print(f"\n✨ Training data ready!")
            print(f"   Raw data: {raw_file}")
            print(f"   Prepared data: {prepared_file}")
    else:
        print("\n⚠️  No data to export. Make sure users are interacting with the app.")


if __name__ == "__main__":
    main()

class WellnessTopic {
  final String title, description, icon;
  final List<String> tips;
  WellnessTopic({
    required this.title,
    required this.description,
    required this.icon,
    required this.tips,
  });
}

final List<WellnessTopic> wellnessTopics = [
  WellnessTopic(
    title: "Anxiety & Stress",
    description: "Feeling overwhelmed? Pause here.",
    icon: "😰",
    tips: [
      "4-7-8 Breathing: Inhale 4s, Hold 7s, Exhale 8s.",
      "Grounding: Name 5 things you see, 4 you feel.",
      "Talk to a friend—don't carry it alone.",
    ],
  ),
  WellnessTopic(
    title: "Digital Detox",
    description: "Unplug to recharge.",
    icon: "📵",
    tips: [
      "Limit scrolling to 30 mins/day.",
      "No phones in bed (blue light ruins sleep).",
      "Unfollow accounts that make you feel bad.",
    ],
  ),
];

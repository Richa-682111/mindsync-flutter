class CBTData {
  static const List<Map<String, String>> distortions = [
    {
      'id': 'catastrophizing',
      'title': 'Catastrophizing',
      'description': 'Expecting the worst possible outcome, even when it is unlikely.',
      'icon': '🌪️',
    },
    {
      'id': 'black_and_white',
      'title': 'Black-and-White Thinking',
      'description': 'Seeing things in extremes—either perfect or a total failure.',
      'icon': '🏁',
    },
    {
      'id': 'overgeneralization',
      'title': 'Overgeneralization',
      'description': 'Taking one negative event and seeing it as a never-ending pattern.',
      'icon': '🔁',
    },
    {
      'id': 'mind_reading',
      'title': 'Mind Reading',
      'description': 'Assuming you know what others are thinking, usually negatively.',
      'icon': '🔮',
    },
    {
      'id': 'self_blame',
      'title': 'Self-Blame',
      'description': 'Taking responsibility for things that are out of your control.',
      'icon': '👉',
    },
    {
      'id': 'emotional_reasoning',
      'title': 'Emotional Reasoning',
      'description': 'Believing that because you feel a certain way, it must be true.',
      'icon': '❤️',
    },
  ];

  static const Map<String, List<String>> supportiveResponses = {
    'catastrophizing': [
      'Take a deep breath. How likely is this worst-case scenario?',
      'You have survived 100% of your bad days so far.',
      'Let\'s focus on what we can control right now.',
      'Even if things don\'t go perfectly, you will find a way to handle it.',
    ],
    'black_and_white': [
      'There is often a lot of middle ground between perfect and terrible.',
      'Progress isn\'t all-or-nothing. Small steps matter.',
      'A minor setback doesn\'t erase all your hard work.',
      'Try to look for the shades of gray in this situation.',
    ],
    'overgeneralization': [
      'One difficult moment does not define your entire journey.',
      'This is a single event, not a permanent rule.',
      'Just because it happened once, doesn\'t mean it will always happen.',
      'Remind yourself of times when things went well.',
    ],
    'mind_reading': [
      'You cannot know for sure what others are thinking unless they tell you.',
      'People are usually much more focused on themselves than on you.',
      'Try asking for clarification instead of guessing.',
      'Give others the benefit of the doubt—they might just be busy or stressed.',
    ],
    'self_blame': [
      'You are being harder on yourself than necessary.',
      'You cannot control everything. Some things just happen.',
      'Mistakes are part of growth, not a measure of your worth.',
      'Be kind to yourself. You did the best you could with what you knew.',
    ],
    'emotional_reasoning': [
      'Not every thought or feeling is a fact.',
      'Feelings change. This feeling will pass.',
      'Pause and look at the situation more gently.',
      'Acknowledge your feeling, but remember it doesn\'t dictate reality.',
    ],
    'default': [
      'You are allowed to improve slowly.',
      'Try speaking to yourself the way you would comfort a friend.',
      'This thought is uncomfortable, but it cannot hurt you.',
      'You are stronger than this single negative thought.',
    ]
  };

  static String getRandomResponse(String distortionId) {
    final responses = supportiveResponses[distortionId] ?? supportiveResponses['default']!;
    responses.shuffle();
    return responses.first;
  }
}

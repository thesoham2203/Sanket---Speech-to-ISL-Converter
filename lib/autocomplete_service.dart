import 'package:sanket/utils.dart' as utils;

class AutocompleteService {
  static List<String> _allWords = [];

  static void initialize() {
    _allWords = [];

    // Add words from utils
    for (int i = 0; i < utils.words.length; i += 2) {
      _allWords.add(utils.words[i]);
    }

    // Add common words
    _allWords.addAll([
      'hello', 'good', 'morning', 'you', 'thank', 'please', 'sorry',
      'help', 'yes', 'no', 'name', 'how', 'what', 'where', 'when',
      'family', 'friend', 'mother', 'father', 'sister', 'brother',
      'school', 'work', 'home', 'happy', 'sad', 'hungry', 'thirsty',
      'water', 'food', 'eat', 'drink', 'sleep', 'wake', 'go', 'come',
      'sit', 'stand', 'walk', 'run', 'read', 'write', 'learn', 'teach',
      'love', 'like', 'want', 'need', 'have', 'get', 'give', 'take',
      'see', 'hear', 'speak', 'understand', 'know', 'think', 'feel',
      'today', 'tomorrow', 'yesterday', 'now', 'later', 'before', 'after',
      'day', 'night', 'week', 'month', 'year', 'time', 'clock',
      'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten',
      'big', 'small', 'hot', 'cold', 'new', 'old', 'young', 'fast', 'slow',
      'good', 'bad', 'right', 'wrong', 'easy', 'hard', 'safe', 'dangerous',
    ]);

    // Remove duplicates
    _allWords = _allWords.toSet().toList();
    _allWords.sort();
  }

  static List<String> getSuggestions(String query) {
    if (query.isEmpty) return [];

    if (_allWords.isEmpty) initialize();

    final lowerQuery = query.toLowerCase();

    // First get exact prefix matches
    List<String> exactMatches = _allWords
        .where((word) => word.toLowerCase().startsWith(lowerQuery))
        .toList();

    // Then get contains matches
    List<String> containsMatches = _allWords
        .where((word) =>
            !word.toLowerCase().startsWith(lowerQuery) &&
            word.toLowerCase().contains(lowerQuery))
        .toList();

    // Combine and limit to 5 suggestions
    return [...exactMatches, ...containsMatches].take(5).toList();
  }

  static List<String> getSmartSuggestions(String previousWord) {
    // Context-aware suggestions based on previous word
    final suggestions = <String, List<String>>{
      'good': ['morning', 'afternoon', 'evening', 'night', 'day'],
      'hello': ['how', 'good', 'nice', 'welcome', 'friend'],
      'thank': ['you', 'very', 'much', 'god', 'everyone'],
      'please': ['help', 'wait', 'come', 'go', 'sit'],
      'how': ['are', 'old', 'many', 'much', 'do'],
      'what': ['is', 'are', 'time', 'name', 'day'],
      'where': ['is', 'are', 'do', 'go', 'live'],
      'i': ['am', 'need', 'want', 'like', 'love', 'have'],
      'you': ['are', 'have', 'need', 'want', 'can'],
    };

    return suggestions[previousWord.toLowerCase()] ?? [];
  }
}


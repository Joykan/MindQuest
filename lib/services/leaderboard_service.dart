class LeaderboardService {
  List<Map<String, dynamic>> players = [];

  void addScore(String name, int xp) {
    players.add({"name": name, "xp": xp});

    players.sort((a, b) => b["xp"].compareTo(a["xp"]));
  }
}

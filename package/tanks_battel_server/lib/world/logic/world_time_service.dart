class WorldTime {
  // DateTime time;
  int turn;

  WorldTime({required this.turn});
  WorldTime copy({int? turn}) {
    return WorldTime(turn: turn ?? this.turn);
  }
}

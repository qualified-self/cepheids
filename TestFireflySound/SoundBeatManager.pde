/// This class supports a CPU-efficient way to deal with beats.
class SoundBeatManager {

  ArrayList<SamplePlayer> players;
  ArrayList<Gain> gains;

  int currentTrack;

  SoundBeatManager(AudioContext ctx, float period, int nTracks, String filename) {
    // Read sample.
    Sample sample = SampleManager.sample(dataPath("") + "/" + filename);

    // Create players.
    players = new ArrayList<SamplePlayer>();
    gains   = new ArrayList<Gain>();
    for (int i=0; i<N_TRACKS; i++) {
      SamplePlayer player = new SamplePlayer(ac, sample);
      player.setKillOnEnd(false);
      player.setLoopType(SamplePlayer.LoopType.NO_LOOP_FORWARDS);
      player.pause(true); // stop

      Gain gain = new Gain(ac, 2, 0);

      gain.addInput(player);
      ac.out.addInput(gain);
      players.add( player );
      gains.add( gain );
    }

    currentTrack = -1;
  }


  float currentTrackGain = 0;
  void update(float weight) {
    // First: check if we need to change track.
    int ct = track();
    if (currentTrack != ct) {
      currentTrack = ct;
      players.get(currentTrack).reTrigger(); // restart sample
      gains.get(currentTrack).setGain(0);
      currentTrackGain = 0;
    }
//    println("t = " + currentTrack + " w=" + weight);

    // Second: adjust gain of current track.
    currentTrackGain = max(currentTrackGain, weight);
    gains.get(currentTrack).setGain(currentTrackGain);
  }

  float seconds() {
    return millis() / 1000.0f;
  }

  float progression() {
    return (seconds() % PERIOD) / PERIOD;
  }

  int track() {
    return min(floor(progression() * N_TRACKS), N_TRACKS-1);
  }
}

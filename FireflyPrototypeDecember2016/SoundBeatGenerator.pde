/// This class supports a CPU-efficient way to deal with beats.
class SoundBeatGenerator {

  // Audio beads objects.
  ArrayList<SamplePlayer> players;
  ArrayList<Gain> gains;
  Gain mainGain;

  // Current track index.
  int currentTrack;

  // Constructor.
  SoundBeatGenerator(AudioContext ac, UGen output, float period, int nTracks, String filename) {
    // Read sample.
    Sample sample = SampleManager.sample(dataPath("") + "/" + filename);

    // Main gain gate.
    mainGain = new Gain(ac, 2, 1);

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
      mainGain.addInput(gain);
      players.add( player );
      gains.add( gain );
    }

    // Send main gain to output.
    output.addInput(mainGain);

    // Init current track to dummy value.
    currentTrack = -1;
  }

  void setGain(float gain) {
    mainGain.setGain(gain);
  }

  float getGain() {
    return mainGain.getGain();
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

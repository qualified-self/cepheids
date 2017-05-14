import java.util.*;

/**
 * This class manages all the audio aspects of the piece
 */
class SoundManager {

  final String AUDIO_FILE_NAME = "heartbeat_abs.mp3";

  class Clip {
    SamplePlayer player;
    Gain gain;

    Clip( String fileName) {
      player = new SamplePlayer(ac, SampleManager.sample(dataPath("") + "/" + fileName));
      gain = new Gain(ac, 2, 1);
      gain.addInput(player);
      masterGain.addInput(gain);
    }

    void play() {
      println("playing");
      player.start();
    }

    void pause() {
      player.pause(true);
    }

    void reset() {
      player.reset();
    }

    void setGain(float g) {
      println("set gain: " + g);
      gain.setGain(g);
    }

    float getGain() {
      return gain.getGain();
    }
  }

  AudioContext ac;
  Gain masterGain;

  SoundBeatGenerator beat;
  Map<String, Clip> clips;

  SoundManager() {
    // Create audio context.
    ac = new AudioContext();
    masterGain = new Gain(ac, 2, 1);

    // Create beat generator.
    beat = new SoundBeatGenerator(ac, masterGain, PERIOD, N_TRACKS, AUDIO_FILE_NAME);

    // Create clips.
    clips = new HashMap<String, Clip>();

    // Add clips.
    addClip("prologue",   "environment_prologue.mp3");
    addClip("soundscape", "environment_intro.mp3");

    ac.out.addInput(masterGain);
  }

  void start() {
    ac.start();
  }

  void reset() {
    for (Map.Entry<String, Clip> clip : clips.entrySet()) {
      clip.getValue().pause();
      clip.getValue().reset();
      clip.getValue().setGain(1);
    }
    beat.setGain(1);
  }

  void addClip(String label, String fileName) {
    clips.put(label, new Clip(fileName));
  }

  Map<String, Clip> getClips() { return clips; }

  Clip getClip(String label) {
    return clips.get(label);
  }

  void setClipGain(String label, float gain) {
    clips.get(label).setGain(gain);
  }

  void setBeatGain(float gain) {
    beat.setGain(gain);
  }

  void setMasterGain(float gain) {
    println("Master gain: " + gain);
    masterGain.setGain(gain);
  }

  float getMasterGain() {
    return masterGain.getGain();
  }

  void update(float weight) {
    beat.update(weight);
  }

}
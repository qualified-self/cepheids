import netP5.*;
import oscP5.*;

/// This class manages the OSC messages in the application.
class OscManager {

  OscP5 oscP5;
  NetAddress remoteLocation;

  OscManager(PApplet app) {
    // start oscP5, listening for incoming messages.
    oscP5 = new OscP5(app, OSC_RECV_PORT);

    // location to send OSC messages
    remoteLocation = new NetAddress(OSC_IP, OSC_SEND_PORT);
  }

  void reset() {
    // env.init();
    // env.start();
    soundManager.reset();
  }

  /// Plugs all messages to appropriate methods.
  void build() {
    // Reset.
    oscP5.plug(this, "reset", "/reset");

    // Beat gain.
    oscP5.plug(soundManager, "setBeatGain", "/audio/beat/gain");

    // Clips gains.
    for (Map.Entry<String, SoundManager.Clip> entry : soundManager.getClips().entrySet()) {
      oscP5.plug(entry.getValue(), "setGain", "/audio/clip/" + entry.getKey() + "/gain");
      oscP5.plug(entry.getValue(), "play",    "/audio/clip/" + entry.getKey() + "/play");
      oscP5.plug(entry.getValue(), "pause",   "/audio/clip/" + entry.getKey() + "/pause");
      oscP5.plug(entry.getValue(), "reset",   "/audio/clip/" + entry.getKey() + "/reset");
    }

    // Master gain.
    oscP5.plug(soundManager, "setMasterGain", "/audio/master/gain");

    // Environment actions.
    oscP5.plug(env, "setPeriod",                "/environment/firefly/period", "f");
    oscP5.plug(env, "setFlashAdjust",           "/environment/firefly/flash-adjust", "f");
    oscP5.plug(env, "setHeartBeatAdjustFactor", "/environment/firefly/heart-beat-adjust-factor", "f");
    oscP5.plug(env, "setIntensity",      "/environment/firefly/intensity", "f");

    oscP5.plug(env, "dePhaseAll",    "/environment/firefly/de-phase-all", "");
    oscP5.plug(env, "dePhase",       "/environment/firefly/de-phase-many", "i");

    oscP5.plug(env, "addFirefly",    "/environment/firefly/add", "");
    oscP5.plug(env, "addFirefly",    "/environment/firefly/add", "f");
    oscP5.plug(env, "removeFirefly", "/environment/firefly/remove", "");

    oscP5.plug(env, "registerBeat",  "/environment/heart/beat", "");
  }

}

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

  /// Plugs all messages to appropriate methods.
  void build() {
    // Beat gain.
    oscP5.plug(soundManager, "setBeatGain", "/audio/beat/gain");

    // Clips gains.
    for (Map.Entry<String, SoundManager.Clip> entry : soundManager.getClips().entrySet())
      oscP5.plug(entry.getValue(), "setGain", "/audio/clip/" + entry.getKey() + "/gain");

    // Master gain.
    oscP5.plug(soundManager, "setMasterGain", "/audio/master/gain");

    // Environment actions.
    oscP5.plug(env, "setPeriod",     "/environment/period", "f");
    oscP5.plug(env, "addFirefly",    "/environment/firefly/add", "");
    oscP5.plug(env, "addFirefly",    "/environment/firefly/add", "f");
    oscP5.plug(env, "removeFirefly", "/environment/firefly/remove", "");
  }

}

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
    oscP5.plug(soundManager, "setBeatGain", "/audio/beat/gain");
    for (Map.Entry<String, SoundManager.Clip> entry : soundManager.getClips().entrySet())
      oscP5.plug(entry.getValue(), "setGain", "/audio/clip/" + entry.getKey() + "/gain");
  }

}

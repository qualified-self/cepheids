/// This class represents the heart of the user.
class Heart {

  float action;

  Heart() {
  }

  void reset() {
    action = 0;
  }

  /// Register a heart beat.
  void beat() {
    action = 1;
  }

  float getAction() {
    return action;
  }

}

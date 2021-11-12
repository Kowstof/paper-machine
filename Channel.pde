class Channel {
  int steps;
  float stepWidth, stepHeight;
  float[] velocities;
  String sample;

  Channel (int mySteps, float myStepWidth, float myStepHeight, String mySample) {
    steps = mySteps;
    stepWidth = myStepWidth;
    stepHeight = myStepHeight;
    sample = dataPath("") + "/" + mySample;
    //beats = new boolean[mySteps];
    velocities = new float[mySteps];
    Arrays.fill(velocities, 0);
  }

  void updateBeat(int index, float newVelocity) { 
    velocities[index] = newVelocity;
  }
}

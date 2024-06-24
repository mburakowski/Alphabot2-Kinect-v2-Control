import java.util.ArrayList;
import KinectPV2.KJoint;
import KinectPV2.*;
import websockets.*;
import processing.video.*;

KinectPV2 kinect;
WebsocketServer wsServer;
Capture cam;  

// Zmienne do śledzenia czasu gestów
int gestureStartTime = 0;
int gestureDurationThreshold = 2000; // 2000 milisekund = 2 sekundy
int currentGesture = -1;

void setup() {
  size(2048, 728, P3D);  

  kinect = new KinectPV2(this);
  kinect.enableDepthMaskImg(true);
  kinect.enableSkeletonDepthMap(true);
  kinect.init();

  wsServer = new WebsocketServer(this, 8080, "/kinect");
  println("WebSocket server started on port 8080");

  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("No cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    cam = new Capture(this, cameras[0]);
    cam.start();
  }
}

void draw() {
  background(0);
  // Wyświetlanie obrazu z Kinecta
  image(kinect.getDepthMaskImage(), 0, 0);

  ArrayList<KSkeleton> skeletonArray = kinect.getSkeletonDepthMap();

  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();

      color col = skeleton.getIndexColor();
      fill(col);
      stroke(col);

      drawBody(joints);
      drawHandState(joints[KinectPV2.JointType_HandRight]);
      drawHandState(joints[KinectPV2.JointType_HandLeft]);
      handleGestures(joints); // Dodano wywołanie funkcji handleGestures
    }
  }

  fill(255, 0, 0);
  text(frameRate, 50, 50);

  if (currentGesture != -1 && millis() - gestureStartTime >= gestureDurationThreshold) {
    println("Gesture detected for 2 seconds: " + gestureName(currentGesture));
    currentGesture = -1; 
  }

  // Wyświetlanie obrazu z normalnej kamery
  if (cam.available() == true) {
    cam.read();
  }
  image(cam, 1024, 0);  // Wyświetlanie obrazu kamery po prawej stronie
}

void drawBody(KJoint[] joints) {
  drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
  drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);
  drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft);

  drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);
  drawBone(joints, KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight);
  drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_ThumbRight);

  drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);
  drawBone(joints, KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft);
  drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_ThumbLeft);

  drawBone(joints, KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight);
  drawBone(joints, KinectPV2.JointType_KneeRight, KinectPV2.JointType_AnkleRight);
  drawBone(joints, KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight);

  drawBone(joints, KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft);
  drawBone(joints, KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft);
  drawBone(joints, KinectPV2.JointType_AnkleLeft, KinectPV2.JointType_FootLeft);

  drawJoint(joints, KinectPV2.JointType_HandTipLeft);
  drawJoint(joints, KinectPV2.JointType_HandTipRight);
  drawJoint(joints, KinectPV2.JointType_FootLeft);
  drawJoint(joints, KinectPV2.JointType_FootRight);

  drawJoint(joints, KinectPV2.JointType_ThumbLeft);
  drawJoint(joints, KinectPV2.JointType_ThumbRight);
  drawJoint(joints, KinectPV2.JointType_Head);
}

void drawJoint(KJoint[] joints, int jointType) {
  pushMatrix();
  translate(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
}

void drawBone(KJoint[] joints, int jointType1, int jointType2) {
  pushMatrix();
  translate(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
  line(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ(), joints[jointType2].getX(), joints[jointType2].getY(), joints[jointType2].getZ());
}

void drawHandState(KJoint joint) {
  noStroke();
  handState(joint.getState(), joint.getType()); 
  pushMatrix();
  translate(joint.getX(), joint.getY(), joint.getZ());
  ellipse(0, 0, 70, 70);
  popMatrix();
}

void handState(int handState, int jointType) { // Dodano jointType
  switch(handState) {
  case KinectPV2.HandState_Open:
    fill(0, 255, 0);
    trackGesture(handState, jointType);
    break;
  case KinectPV2.HandState_Closed:
    fill(255, 0, 0);
    trackGesture(handState, jointType);
    break;
  case KinectPV2.HandState_Lasso:
    fill(0, 0, 255);
    trackGesture(handState, jointType);
    break;
  case KinectPV2.HandState_NotTracked:
    fill(100, 100, 100);
    currentGesture = -1; // Resetuj gest, jeśli nie jest śledzony
    break;
  }
}

void trackGesture(int handState, int jointType) {
  int gestureId = handState + jointType * 10; 
  if (currentGesture == gestureId) {
    if (millis() - gestureStartTime >= gestureDurationThreshold) {
      println("Gesture detected for 2 seconds: " + gestureName(currentGesture));
      wsServer.sendMessage(gestureName(currentGesture)); 
      currentGesture = -1; 
    }
  } else {
    currentGesture = gestureId;
    gestureStartTime = millis();
  }
}

String gestureName(int gesture) {
  int handState = gesture % 10;
  int jointType = gesture / 10;
  String handName = jointType == KinectPV2.JointType_HandRight ? "Right Hand" : "Left Hand";
  switch(handState) {
  case KinectPV2.HandState_Open:
    return handName + " Open";
  case KinectPV2.HandState_Closed:
    return handName + " Closed";
  case KinectPV2.HandState_Lasso:
    return handName + " Lasso";
  default:
    return "Unknown Gesture";
  }
}

void handleGestures(KJoint[] joints) {
  int rightHandState = joints[KinectPV2.JointType_HandRight].getState();
  int leftHandState = joints[KinectPV2.JointType_HandLeft].getState();
  
  String gestureMessage = "";

  if (rightHandState == KinectPV2.HandState_Open) {
    gestureMessage = "RIGHT_HAND_OPEN";
  } else if (rightHandState == KinectPV2.HandState_Closed) {
    gestureMessage = "RIGHT_HAND_CLOSED";
  } else if (rightHandState == KinectPV2.HandState_Lasso) {
    gestureMessage = "RIGHT_HAND_LASSO";
  }

  if (leftHandState == KinectPV2.HandState_Open) {
    gestureMessage += " LEFT_HAND_OPEN";
  } else if (leftHandState == KinectPV2.HandState_Closed) {
    gestureMessage += " LEFT_HAND_CLOSED";
  } else if (leftHandState == KinectPV2.HandState_Lasso) {
    gestureMessage += " LEFT_HAND_LASSO";
  }

  if (!gestureMessage.isEmpty()) {
    println("Sending WebSocket message: " + gestureMessage);
    wsServer.sendMessage(gestureMessage);
    println("Gesture sent: " + gestureMessage);
  }
}

import * as Meyda from "meyda";
let meyda;

async function startCapture(displayMediaOptions) {
  let captureStream;
  try {
    captureStream = await navigator.mediaDevices.getDisplayMedia(
        displayMediaOptions
    );
  } catch (err) {
    console.error(`Error: ${err}`);
  }
  return captureStream;
}

const Audio = async function (bufferSize) {
  let context = new AudioContext();
  let stream = await startCapture({audio:true,video:true})
  let source = context.createMediaStreamSource(stream);
  meyda = Meyda.createMeydaAnalyzer({
    audioContext: context,
    source: source,
    bufferSize: bufferSize,
    windowingFunction: "blackman",
  });

};

let AudioGet = function (features) {
  return meyda.get(features);
};

let GetMeyda = function(){
  return meyda
}

export{ Audio,AudioGet,GetMeyda};

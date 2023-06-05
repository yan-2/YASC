let noteOptions = ["D4","A3","F#3","B3","C#4","C4","F#4","A4","B4","G4","E4","F4","C5","D5","E5","","freestyle"].sort()
let leftOperationsMap ={
        upAmplitude : '↑amplitude',
        downAmplitude:'↓amplitude',
        upAttack:'↑attack time of envelope',
        downAttack:'↓attack time of envelope',
        upRelease:'↑release time of envelope',
        downRelease:'↓release time of envelope',
        upFrequency:'↑frequency of vibrato',
        downFrequency:'↓frequency of vibrato',
        upDepth:'↑depth of vibrato',
        downDepth:'↓depth of vibrato',
        upMix:'↑Mix D/W of reverb',
        downMix:'↓Mix D/W time of reverb',
        upReverbTime:'↑time of reverb',
        downReverbTime:'↓time of reverb',
        upPreDelay:'↑pre-delay of reverb',
        downPreDelay:'↓pre-daly of reverb',
        amplitude:'amplitude',
        closeFreestyle:'Close freestyle sound '
}

let leftOperations = Object.values(leftOperationsMap).concat([""])

let defaultHotkeys = {
        // right
        A:'C4',
        B:'D4',
        X:'E4',
        Y:'F4',
        R:'G4',
        ZR:'A4',
        HomeButton:'',
        PlusButton:'',
        SRButton:'',
        slButton:'',
        LStickTop:'',
        LStickDown:'',
        LStickLeft:'',
        LStickRight:'',
        // left
    // 'Kick','Snare','Hi-hat'
        Up:leftOperationsMap.upAmplitude,
        Down:leftOperationsMap.downAmplitude,
        Left:leftOperationsMap.upRelease,
        Right:leftOperationsMap.downRelease,
        L:'',
        ZL:'',
        // LeftTwist:'',
        LVerticalMove:'',
        lOrientationBeta:'',
        lOrientationGamma:'',
        lOrientationBetaAlpha:'',
        RVerticalMove:''
}
export {defaultHotkeys,noteOptions,leftOperations,leftOperationsMap}

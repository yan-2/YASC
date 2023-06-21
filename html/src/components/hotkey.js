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
        "A": "A3",
        "B": "F#3",
        "X": "D4",
        "Y": "B3",
        "R": "E4",
        "ZR": "F4",
        "HomeButton": "G4",
        "PlusButton": "B4",
        "SRButton": "C5",
        "slButton": "D5",
        "Up": "↑amplitude",
        "Down": "↓amplitude",
        "Left": "↑Mix D/W of reverb",
        "Right": "↓Mix D/W time of reverb",
        "L": "↑amplitude",
        "ZL": "↑amplitude",
        "LeftTwist": "↑amplitude",
        "LeftShake": "↑amplitude",
        "LStickTop": "C#4",
        "LStickDown": "F#4",
        "LStickLeft": "A4",
        "LStickRight": "C4",
        "LVerticalMove": "amplitude",
        "RVerticalMove": "freestyle"
}
export {defaultHotkeys,noteOptions,leftOperations,leftOperationsMap}

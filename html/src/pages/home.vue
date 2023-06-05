<template>
    <div class="container" >
        <div class="align" id="align">
            <h1 id="title" @click="bind">****</h1>
            <div id="start">
                <p @click="go('hotkeys')">Custom Hotkeys</p>
                <p @click="go('dino')">Game Training</p>
                <p @click="go('stft')">Play your own style</p>
            </div>

        </div>
    </div>
</template>

<script>

let characters_up = [
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z"
];
let characters_low = [
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    "o",
    "p",
    "q",
    "r",
    "s",
    "t",
    "u",
    "v",
    "w",
    "x",
    "y",
    "z"
];
let title = ["*", "*", "*", "*"];
function update_txt(title) {
    let string = "";
    title.forEach((element) => {
        string += element;
    });
    document.getElementById("title").innerHTML = string;
}
let myFuncUpper = function (char_num, num) {
    let i = 0;
    let character0 = 0;
    while (i < char_num) {
        (function (i) {
            setTimeout(function () {
                character0 = characters_up[i];
                title[num] = character0;
                //console.log(i)
                update_txt(title);
            }, 100 * i);
        })(i++);
    }
    return true;
};

let myFuncLower = function (char_num, num) {
    let i = 0;
    let character0 = 0;
    while (i < char_num) {
        (function (i) {
            setTimeout(function () {
                character0 = characters_low[i];
                title[num] = character0;
                //console.log(i)
                update_txt(title);
            }, 100 * i);
        })(i++);
    }
    return true;
};
let complete = 0;
export default {
    name: "start_page.vue",
    mounted() {
        let me = this;
        me.intro()
    },
    inject: ['connect'],
    methods:{
        async bind(){
            let me = this
            me.connect()
        },
        go(name){
            let me = this;
            if (complete === 3) {
                document.getElementById("align").style.top = "40%";
                document.getElementById("align").style.opacity = "0%";
                setTimeout(function () {
                    //put the start location here
                    me.$router.push({ path: `/game/${name}` })
                }, 1200);
            }
        },
        intro(){
            complete = 1;
            setTimeout(function () {
                complete = 2;
                //YASC
                myFuncUpper(25, 0);
                myFuncUpper(1, 1);
                myFuncUpper(19, 2);
                myFuncUpper(3, 3);
            }, 1000);

            setTimeout(function () {
                complete = 3;
                document.getElementById("title").style.border = "solid 5px white";
                document.getElementById("start").style.top = "10%";
                setTimeout(()=>{
                    document.getElementById("start").style.opacity = '1';
                },300)
            }, 3400);
        }
    }
}
</script>

<style lang="less" scoped >
.container{
    width: 100%;
    height: 100%;
    background-color: black;
    color: white;
    font-family: "Source Code Pro", monospace;

}
#title{
    background: black;
}
.container {
    flex-direction: column;
    display: flex;
    width: 100vw;
    height: 100vh;
    user-select: none;
    overflow: hidden;
}

.align {
    flex-direction: column;
    display: flex;
    margin: auto;
    position: relative;
    top: 0px;
    opacity: 1;
    transition: 1s ease-out;
h1 {
    font-size: 40px;
    padding: 5px;
    transition: 0.5s border ease;
    z-index: 1;
}

#start {
    text-align: center;
    position: relative;
    top: -50%;
    opacity: 0;
    transition: 1s top ease-out;
    p{
        display: block;
        cursor: pointer;
        margin:10px 0;
        &:hover{
            color: red;
        }
    }
}
}
#title{
    padding: 15px 60px;
    text-align: center;
    cursor: pointer;
}

</style>

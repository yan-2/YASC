import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import Notifications from '@kyvg/vue3-notification'
import * as utils from './components/utils.js'

import Dino from './pages/dino.vue'
import Stft from './pages/stft.vue'
import Home from './pages/home.vue'
import Hotkeys from './pages/hotkeys.vue'
import DefaultPage from './default.vue'

import './assets/reset.css'
import './assets/pure-min.css'

const routes = [
    {
        path: '/',
        name:'start',
        component: Home,
    },
    {
        path: '/game/',
        children: [
            {
                path: 'hotkeys',
                component: Hotkeys,
            },
            {
                path: 'dino',
                component: Dino,
            },
            {
                path: 'stft',
                component: Stft,
            }
        ],
    },
]
const router = createRouter({
    history: createWebHistory(),
    routes, // short for `routes: routes`
})

const app = createApp(DefaultPage,)
app.config.globalProperties.$utils = utils;
// const app = createApp(App)
app.use(router)
app.use(Notifications)
// test
app.mount('#app')




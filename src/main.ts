import {Elm} from '@/Main.elm'
import Dialog from '@/UI/dialog'

const node = document.getElementById('app')

Elm.Main.init({node, flags: null})
customElements.define('elm-dialog', Dialog)

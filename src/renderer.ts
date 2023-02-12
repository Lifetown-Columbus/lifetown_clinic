const info = document.getElementById('info')
const versions = window.versions

if (info) {
    info.innerText =  `This app is using Chrome (v${versions.chrome()}), Node.js (v${versions.node()}), and Electron (v${versions.electron()})`
}

const func = async () => {
    const res = await versions.ping()
    console.log(res)
}

func()
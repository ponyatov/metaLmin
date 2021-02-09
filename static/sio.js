// SocketIO bindings

sio = io()

sio.on('connect',(info)=>{
    console.log('sio','connect',info)
    $('#localtime').addClass('online').removeClass('offline')
})

sio.on('disconnect',(info)=>{
    console.log('sio','disconnect',info)
    $('#localtime').addClass('offline').removeClass('online')
})

sio.on('localtime',(info)=>{
    console.log('sio','localtime',info)
    $('#localtime').text(info.date+" "+info.time)
})

sio.on('reload',(info)=>{
    console.log('sio','reload',info)
    document.location.reload()
})

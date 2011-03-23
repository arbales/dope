DocumentCache = {
  postLeft: 0      
  post:0
}
Event.addBehavior {
  ".post .image:click": ->
      window.location.href = "/post/#{this.up('.post').readAttribute('data-id')}"
  "#overlay:click": ->
    this.fade();
    $$('.popup')[0].hide();
    
  "input.delete:click": ->
    this.up('.deletable').fade();
    new Ajax.Request(this.readAttribute('data-target'), {
      method: 'delete'
    })
  "h1:click": (event)->
    window.location.href = "/" 
  "input.yeps:click": ->
    new Ajax.Request("post/#{this.up('.post').readAttribute('data-id')}/yeps", {
      method: 'put' 
      onSuccess: (transport) =>   
        console.log transport.responseText
        this.value = "yeps #{transport.responseText}"
    })             
    Event.stop event  
  "input.nopes:click": ->
    new Ajax.Request("post/#{this.up('.post').readAttribute('data-id')}/nopes", {
      method: 'put' 
      onSuccess: (transport) =>   
        console.log transport.responseText
        this.value = "nopes #{transport.responseText}"
    })             
    Event.stop event 
  "input[type=button]:click": ->
    this.addClassName "on"  
    #DocumentCache.postLeft -= 500
    #$$('.posts')[0].morph("margin-left:#{DocumentCache.postLeft}px")
#    DocumentCache.post -= 1        
  "input[type=button]:click": ->
    this.removeClassName "on"
  ".post form.commenter:submit": (event)->
    el = this
    Event.stop(event)
    this.request({
      onComplete: ->    
        el.appear({engine:'javascript'})
        comment = new Element 'p', {class: 'deletable'}
        comment.update("<span class='body'>#{el.down('input[type=text]').value}</span>")
        el.previous('h3').insert {after: comment}
        el.down('input[type=text]').clear()
    })
  ".poster:submit": (event) -> 
    #if not this.hasClassName "ready"
    Event.stop event  
    el = this  
    el.addClassName 'ready'                 
    this.up('.popup').addClassName 'out'
    $('overlay').morph "opacity:1" 
    $$('.primary')[0].show()
    $('song').play() 
    setTimeout (->    
      el.submit()
      ), 5000
       
  ".new-upload:click": ->
    $('overlay').appear()
    $$('.popup')[0].show() 
  }
    
document.observe "dom:loaded", ->
  if $('movealong')
    overlay.show()
    
    $('song').play()

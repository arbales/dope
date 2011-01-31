DocumentCache = {
  postLeft: 0      
  post:0
}
Event.addBehavior {
  ".no.post:click": ->
    if this.hasClassName 'in'
      this.insert({after: this.next().clone(true)});
    else
      this.addClassName "out"
    #else
    #  this.addClassName "left"  
  "input.delete:click": ->
    this.up('.deletable').fade();
    new Ajax.Request(this.readAttribute('data-target'), {
      method: 'delete'
    })
  "h1:click": ->
    #$$('.out')[0].removeClassName('out').addClassName('in')
    $('overlay').show() 
    $$('.primary')[0].show()
    $('song').play()
    
  "input[type=button]:click": ->
    this.addClassName "on"  
    #DocumentCache.postLeft -= 500
    #$$('.posts')[0].morph("margin-left:#{DocumentCache.postLeft}px")
#    DocumentCache.post -= 1    
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
    $('overlay').setStyle('display:block').addClassName("appear")
    $$('.popup')[0].show() 
  }
    
document.observe "dom:loaded", ->
  if $('movealong')
    overlay.show()
    
    # $('song').play()

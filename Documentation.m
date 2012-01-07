# Fidget - Documentation

Copyright © Simon Boak 2011.
http://www.simonboak.co.uk/fidget



## Quickstart

(quickstart demo here)



## Methods

### fidget

The Fidget method is used to attach the event handlers to a DOM object. It's full list of options and the internal defaults are are:

<code>
$(element).fidget({
	swipe: null,
	dragThis: false,
	pinch: null,
	zoomThis: false,
	rotateThis: false,
	tap: null,
	doubleTap: null
});
</code>



* swipe: this option defines a function to accept the event when a swipe occurs on the target element. This event is called on swipe start, move and end.
* dragThis: when set to true, the target element will be dragged around the page, all handled by Fidget making it easy to create draggable objects. Swipe (above) still gets called.
* pinch: this option defines a function to accept the event when a pinch occurs on the target element. This event is called on swipe start, move and end.
* zoomThis: when set to true, the target element's dimensions will be scaled up when it is a pinch out event, and scaled down when it is a pinch in event. Pinch (above) still gets called.
* rotateThis: when set to true, the CSS3 rotation property is changed on the target element to rotate as the first 2 fingers rotate from their original position. The origin of rotation is set to the centre coordinates of the pinch.
* tap: this option defines a function to accept tap events.
* doubleTap: this option defines a function to accept a double tap event. On the first tap the above event will be called, if the second tap occurs within 1 second the doubleTap event is triggered.




### resetFidget

resetFidget can be used to set all of the properties of the fidget object. This does not remove the event bindings.

<code>
$(element).resetFidget();
</code>


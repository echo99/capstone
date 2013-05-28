/**
 * @externs
 * @suppress {duplicate}
 */

/**
* @param {number} x
* @param {number} y
* @param {number} radius
* @param {number} startAngle
* @param {number} endAngle
* @param {boolean=} anticlockwise
*/
CanvasRenderingContext2D.prototype.arc = function(x, y, radius ,startAngle, endAngle, anticlockwise){}

/**
* @param {string} type
* @param {(EventListener|function ((Event|null)): (boolean|undefined)|null)} listener
* @param {boolean=} useCapture
*/
Node.prototype.addEventListener = function(type, listener, useCapture){}

/** @suppress {checkTypes} */
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
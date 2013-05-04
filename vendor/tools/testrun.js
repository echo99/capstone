load('env.rhino.1.2.js');
Envjs.scriptTypes['text/javascript'] = true;
window.location = '../../public/index.html';
// console.log("hello!!!");
// var frame = document.getElementById('frame');
// console.log(frame);
CanvasRenderingContext2D.prototype.measureText = function() {
  return {width: 100};
};
CanvasRenderingContext2D.prototype.fillText = function() {};
CanvasRenderingContext2D.prototype.canvas = {width: 2000, height: 1500};
window.TESTING = true;
load('../../public/vendor.js');
load('../../public/app.js');
// console.log("Hii!");
// Envjs.afterScriptLoad = function() {
//   console.log("Sript loaded!!!!!!!!!!!");
// };
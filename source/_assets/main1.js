(function() {
  var term = new Console('container');
  term.init();

  toggleHelp = function() {
    document.querySelector('.help').classList.toggle('hidden');
    document.body.classList.toggle('dim');
  };


  document.body.addEventListener('keydown', function(e) {
    if (e.keyCode == 27) { // Esc
      toggleHelp();
      e.stopPropagation();
      e.preventDefault();
    }
  }, false);



})();
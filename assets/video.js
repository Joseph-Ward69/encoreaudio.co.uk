// Swaps the demo video's still for the YouTube player (privacy-enhanced mode) only when the visitor presses play.
document.querySelectorAll('.video-play').forEach(function (b) {
  b.addEventListener('click', function () {
    var f = document.createElement('div');
    f.className = 'video-frame';
    var i = document.createElement('iframe');
    i.src = 'https://www.youtube-nocookie.com/embed/' + b.dataset.video + '?autoplay=1&rel=0&playsinline=1';
    i.title = 'Encore Audio app demo';
    i.allow = 'autoplay; encrypted-media; picture-in-picture; fullscreen';
    f.appendChild(i);
    b.replaceWith(f);
  });
});

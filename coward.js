// Coward - One time or periodic refresh that retreats of anything goes wrong.
//
// This tool was designed for use with jQuery 1.9 or later

function Coward(custom) {
  'use strict';
//==============================================
// Options and variables used by the coward
// - Do not change `opts` after invocation -
//==============================================
  var opts = $.extend({
    url: 'localhost',
    elem: '#none',
    frequency: 1000,
    retries: 10,
    multiple: 1.5,
    timeout: 3000
  }, custom);

  if (opts.multiple < 1) {
    // multiple less than one results in increasing frequency on fail
    console.log("Multiple CANNOT be less than one!");
    return false;
  }

  var running = false;
  var fails = 0;
  var next = opts.frequency;

//==========================================================
// Main body of Coward (_run, _success, _fail)
// - DO NOT call these functions directly -
// - INSTEAD use Start, DelayStart, Stop, and RunOnce -
//==========================================================
  function _run() {
    if (!running) {
      return false;
    }

    $.ajax({
      url: opts.url,
      method: 'GET',
      success: _success,
      error: _fail,
      timeout: opts.timeout
    });
    return true;
  }

  function _success(data) {
    // If there are failures, start to scale up requests again
    if (fails > 0) {
      fails--;
      next = Math.round(next/opts.multiple);
      console.log("Success! Recovered a white flag, now have "+fails+". Next attempt in "+next);
    }
    // Replace the element with the response and set the next run
    console.log("Success!");
    $(opts.elem).html(data);
    if (next > 0) {
      setTimeout(_run, next);
    }
  }

  function _fail() {
    // If we have fails left, log the incident and continue, otherwise stop.
    if (fails < opts.retries) {
      next = Math.round(next * opts.multiple);
      console.log('Refresh for selector '+opts.elem+' failed. '+(opts.retries-fails)+' white flags remaining. Retreating to '+next+' [front line at '+opts.frequency+'].');
      fails++;
      setTimeout(_run, next);
    } else {
      console.log('Refresh for selector '+opts.elem+' has failed '+fails+' times. I surrender!');
      running = false;
    }
  }


//===============================================
// Publicly Accessible Functions
//===============================================
  var Start = function() {
    // Reset vars in case of Stop/Start cycle
    fails = 0;
    next = opts.frequency;
    running = true;
    return _run();
  };

  var DelayStart = function(delay) {
    // Start after user provided delay or one "frequency cycle"
    if (delay === undefined) {
      setTimeout(Start, opts.frequency);
      return opts.frequency;
    }
    setTimeout(Start, delay);
    return delay;
  };

  var Stop = function() {
    // Stop the run function from creating new ajax calls
    running = false;
    return false;
  };

  var RunOnce = function() {
    // Perform the ajax call but do not set future intervals
    running = true;
    next = -1;
    return _run();
  };

  return {
    Start: Start,
    DelayStart: DelayStart,
    Stop: Stop,
    RunOnce: RunOnce
  };
}


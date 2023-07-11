// MIT License © Zeno Rocha
function select(element) {
    var selectedText;
    if (element.nodeName === 'SELECT') {
        element.focus();

        selectedText = element.value;
    }
    else if (element.nodeName === 'INPUT' || element.nodeName === 'TEXTAREA') {
        var isReadOnly = element.hasAttribute('readonly');
        if (!isReadOnly) {
            element.setAttribute('readonly', '');
        }
        element.select();
        element.setSelectionRange(0, element.value.length);
        if (!isReadOnly) {
            element.removeAttribute('readonly');
        }
        selectedText = element.value;
    }
    else {
        if (element.hasAttribute('contenteditable')) {
            element.focus();
        }
        var selection = window.getSelection();
        var range = document.createRange();
        range.selectNodeContents(element);
        selection.removeAllRanges();
        selection.addRange(range);

        selectedText = selection.toString();
    }
    return selectedText;
}

/*!
 * clipboard.js v2.0.11
 * https://clipboardjs.com/
 *
 * Licensed MIT © Zeno Rocha
 */
function createFakeElement(value) {
  const isRTL = document.documentElement.getAttribute('dir') === 'rtl';
  const fakeElement = document.createElement('textarea');
  // Prevent zooming on iOS
  fakeElement.style.fontSize = '12pt';
  // Reset box model
  fakeElement.style.border = '0';
  fakeElement.style.padding = '0';
  fakeElement.style.margin = '0';
  // Move element out of screen horizontally
  fakeElement.style.position = 'absolute';
  fakeElement.style[isRTL ? 'right' : 'left'] = '-9999px';
  // Move element to the same position vertically
  let yPosition = window.pageYOffset || document.documentElement.scrollTop;
  fakeElement.style.top = `${yPosition}px`;

  fakeElement.setAttribute('readonly', '');
  fakeElement.value = value;

  return fakeElement;
}

function command(type) {
  try {
    return document.execCommand(type);
  } catch (err) {
    return false;
  }
}

function copyText(text) {
    const fakeElement = createFakeElement(text);

    document.body.appendChild(fakeElement);
    const selectedText = select(fakeElement);
    const ret = command('copy');
//    if(ret === true) {
//        window.parent.postMessage('copy-success#' + text, "*");
//    }
    fakeElement.remove();
    return ret;
}

window.logger = (flutter_value) => {
//   console.log({ js_context: this, flutter_value });
}
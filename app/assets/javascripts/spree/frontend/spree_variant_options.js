$.extend({
  keys: function(obj){
    var a = [];
    $.each(obj, function(k){ a.push(k); });
    return a;
  }
});

if (!Array.indexOf) Array.prototype.indexOf = function(obj) {
  for(var i = 0; i < this.length; i++){
    if(this[i] == obj) {
      return i;
    }
  }
  return -1;
};

if (!Array.find_matches) Array.find_matches = function(a) {
  var i, m = [];
  a = a.sort();
  i = a.length;
  while(i--) {
    if (a[i - 1] == a[i]) {
      m.push(a[i]);
    }
  }
  if (m.length == 0) {
    return false;
  }
  return m;
};

function VariantOptions(params) {

  var options = params['options'];
  var allow_backorders = true;

  var variant, divs, parent, index = 0;
  var selection = [];
  var buttons;

  function init() {
    divs = $('#product-variants .variant-options');
    disable(divs.find('a.option-value').addClass('locked'));
    update();
    enable(parent.find('a.option-value'));
    toggle();
    $('#stock a').first().addClass('active')
    $('.clear-option a.clear-button').hide().click(handle_clear);
    divs.each(function(){
      $(this).find("ul.variant-option-values li .roundedOne.in-stock:first").click()
    });
  }

  function get_index(parent) {
    return parseInt($(parent).attr('class').replace(/[^\d]/g, ''));
  }

  function update(i) {
    index = isNaN(i) ? index : i;
    parent = $(divs.get(index));
    buttons = parent.find('a.option-value');
    parent.find('a.clear-button').hide();
  }

  function disable(btns) {
    return btns.removeClass('selected');
  }

  function enable(btns) {
    bt = btns.not('.unavailable').removeClass('locked').unbind('click');
    return bt.click(handle_click).filter('.auto-click').removeClass('auto-click').click();
  }

  function advance() {
    index++;
    update();
    inventory(buttons.removeClass('locked'));
    enable(buttons);
  }

  function inventory(btns) {
    var keys, variants, count = 0, selected = {};
    var sels = $.map(divs.find('a.selected'), function(i) { return i.rel; });
    $.each(sels, function(key, value) {
      key = value.split('-');
      var v = options[key[0]][key[1]];
      keys = $.keys(v);
      var m = Array.find_matches(selection.concat(keys));
      if (selection.length == 0) {
        selection = keys;
      } else if (m) {
        selection = m;
      }
    });
    btns.removeClass('in-stock out-of-stock unavailable').each(function(i, element) {
      variants = get_variant_objects(element.rel);
      keys = $.keys(variants);
      if (keys.length == 0) {
        disable($(element).addClass('unavailable').unbind('click'));
      } else if (keys.length == 1) {
        _var = variants[keys[0]];
        $(element).addClass((_var.count || _var.backorderable || _var.special_stock) ? selection.length == 1 ? 'in-stock auto-click' : 'in-stock' : 'out-of-stock');
      } else if (allow_backorders) {
        $(element).addClass('in-stock');
      } else {
        $.each(variants, function(key, value) { count += value.count; });
        $(element).addClass(count ? 'in-stock' : 'out-of-stock');
      }
      if($(element).hasClass('out-of-stock')){
        disable($(element).addClass('unavailable').unbind('click'));
      }
    });
  }

  function get_variant_objects(rels) {
    var i, ids, obj, variants = {};
    if (typeof(rels) == 'string') { rels = [rels]; }
    var otid, ovid, opt, opv;
    i = rels.length;
    try {
      while (i--) {
        ids = rels[i].split('-');
        otid = ids[0];
        ovid = ids[1];
        opt = options[otid];
        if (opt) {
          opv = opt[ovid];
          ids = $.keys(opv);
          if (opv && ids.length) {
            var j = ids.length;
            while (j--) {
              obj = opv[ids[j]];
              if (obj && $.keys(obj).length && 0 <= selection.indexOf(obj.id.toString())) {
                variants[obj.id] = obj;
              }
            }
          }
        }
      }
    } catch(error) {
      console.log(error);
    }
    return variants;
  }

  function to_f(string) {
    return parseFloat(string.replace(/[^\d\.]/g, ''));
  }

  function find_variant() {
    var selected = divs.find('a.selected');
    var variants = get_variant_objects(selected.get(0).rel);
    if (selected.length == divs.length) {
      return variant = variants[selection[0]];
    } else {
      var prices = [];
      $.each(variants, function(key, value) { prices.push(value.price); });
      prices = $.unique(prices).sort(function(a, b) {
        return to_f(a) < to_f(b) ? -1 : 1;
      });
      if (prices.length == 1) {
        $('#product-price .price').html('<span class="price assumed">' + prices[0] + '</span>');
      } else {
        $('#product-price .price').html('<span class="price from">' + prices[0] + '</span> - <span class="price to">' + prices[prices.length - 1] + '</span>');
      }
      return false;
    }
  }

  function toggle() {
    if (variant) {
      $('#variant_id, form[data-form-type="variant"] input[name$="[variant_id]"]').val(variant.id);
      $('#product-price .price').removeClass('unselected').text(variant.price);
      if (variant.count > 0 || variant.backorderable || variant.special_stock)
        $('#cart-form button[type=submit]').attr('disabled', false).fadeTo(0.5, 1);
      $('form[data-form-type="variant"] button[type=submit]').attr('disabled', false).fadeTo(0.5, 1);
      try {
        show_variant_images(variant.id);
      } catch(error) {
        // depends on modified version of product.js
      }
    } else {
      $('#variant_id, form[data-form-type="variant"] input[name$="[variant_id]"]').val('');
      price = $('#product-price .price').addClass('unselected');
      // Replace product price by "(select)" only when there are at least 1 variant not out-of-stock
      variants = $("div.variant-options.index-0");
      if (variants.find("a.option-value.out-of-stock").length != variants.find("a.option-value").length)
        price.text('(select)');
    }
  }

  function clear(i) {
    variant = null;
    update(i);
    enable(buttons.removeClass('selected'));
    toggle();
    parent.nextAll().each(function(index, element) {
      disable($(element).find('a.option-value').show().removeClass('in-stock out-of-stock').addClass('locked'));
      $(element).find('a.clear-button').hide();
    });
    //show_all_variant_images();
  }


  function handle_clear(evt) {
    evt.preventDefault();
    clear(get_index(this));
  }

  function handle_click(evt) {
    evt.preventDefault();
    var last_size = $(".option-value.selected.Size").attr("rel")
    var last_color = $(".option-value.selected.roundedOne").attr("rel")
    variant = null;
    selection = [];
    var el = $(this);
    if (!parent.has(el).length) {
      clear(divs.index(el.parents('.variant-options:first')));
    }
    disable(buttons);
    var a = enable(el.addClass('selected'));
    parent.find('a.clear-button').css('display', 'block');
    advance();
    if (find_variant()) {
      toggle();
    }

    $('.Size a.Size').parent().css('display', 'block')
    if($('#stock a.active').is('#in-stock')){
      $('.Size a.Size.out-of-stock').parent().css('display', 'none')
    }

    if($(".variant-options.Color").length != 0 && last_color != $(".option-value.selected.roundedOne").attr("rel")){
      if($("[rel='" + last_size + "']").hasClass("out-of-stock")){
        $(".Size.in-stock").first().click()
      } else{
        $("[rel='" + last_size + "']").click()
      }
    }

    if($(".popover").css("display") === "block"){
      $(".popover").css("display", "none")
    }
  }

  init();

};

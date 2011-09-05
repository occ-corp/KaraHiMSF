// # -*- coding: utf-8 -*-

var TransferSelect = Class.create();

TransferSelect.prototype = {
    initialize:function(args) {
        this.srcSelect = $(args['srcSelectId']);
        this.dstSelect = $(args['dstSelectId']);
        this.toSrcTrigger = $(args['toSrcTriggerId']);
        this.toDstTrigger = $(args['toDstTriggerId']);
        this.hiddenDstSelect = $(args['hiddenDstSelectId']);
        this.onChangeHander = $(args['onChangeHander']);

        var errMessage = '';
        if (!this.srcSelect) {
            errMessage += 'srcSelectId is invalid. ';
        }
        if (!this.dstSelect) {
            errMessage += 'dstSelectId is invalid. ';
        }
        if (!this.toSrcTrigger) {
            errMessage += 'toSrcTriggerId is invalid. ';
        }
        if (!this.toDstTrigger) {
            errMessage += 'toDstTriggerId is invalid. ';
        }
        if (!this.hiddenDstSelect) {
            errMessage += 'hiddenDstSelectId is invalid. ';
        }
        if (!errMessage.empty()) {
            throw errMessage;
        }

        this.toDstTrigger.observe('click',
                                  this.makeCallback(this.srcSelect, this.dstSelect));

        this.toSrcTrigger.observe('click',
                                  this.makeCallback(this.dstSelect, this.srcSelect));
    },

    makeCallback:function(srcSelect, dstSelect) {
        var hiddenDstSelect = this.hiddenDstSelect;
        var fixedDstSelect = this.dstSelect;
        var updateHiddenDstSelect = this.updateHiddenDstSelect;
        var transferOptions = this.transferOptions;
        var onChangeHander = this.onChangeHander;
        return function (e) {
            transferOptions(srcSelect, dstSelect);
            updateHiddenDstSelect(hiddenDstSelect, fixedDstSelect);
            if (typeof(onChangeHander) == 'function') {
                onChangeHander(e);
            }
            return false;
        };
    },

    updateSrcOptions:function(parsedResponse) {
        var selecteds =
            $A(this.dstSelect.childNodes).collect(function (e) {
                                                      return(e.value);
                                                  });
        var srcs = this.srcSelect.options;
        srcs.length = 0; // clear
        parsedResponse.each(function (e) {
                                var value = e['value'];
                                var caption = e['caption'];
                                if (!selecteds.include(value)) {
                                    srcs.add(new Option(caption, value));
                                }
                            });
    },

    updateHiddenDstSelect:function (hiddenDstSelect, dstSelect)
    {
        hiddenDstSelect.value =
            $A(dstSelect.options).collect(function (e) {
                                              return e.value;
                                          }).join();
    },

    transferOptions:function (srcSelect, dstSelect)
    {
        var dstOptions = dstSelect.options;
        $A(srcSelect.options).select(function (e) {
                                         if (e.selected) {
                                             return e;
                                         }
                                     }).each(function (e) {dstSelect.appendChild(e)});
    },

    parsePeopleResponse:function (response)
    {
        var xml = response.responseXML;
        if (xml !== undefined) {
            return $A(xml.getElementsByTagName('person')).collect(function (e) {
                                                                      return {
                                                                          value:e.getElementsByTagName('id')[0].firstChild.nodeValue,
                                                                          caption:e.getElementsByTagName('name')[0].firstChild.nodeValue
                                                                      };
                                                                  });
        } else {
            new Array();
        }
    },

    parseUsersResponse:function (response)
    {
        var xml = response.responseXML;
        if (xml !== undefined) {
            return $A(xml.getElementsByTagName('user')).collect(function (e) {
                                                                      return {
                                                                          value:e.getElementsByTagName('id')[0].firstChild.nodeValue,
                                                                          caption:e.getElementsByTagName('name')[0].firstChild.nodeValue
                                                                      };
                                                                  });
        } else {
            new Array();
        }
    },

    updateSrcOptionsByPeopleResponse:function (response)
    {
        this.updateSrcOptions(this.parsePeopleResponse(response));
    },

    updateSrcOptionsByUsersResponse:function (response)
    {
        this.updateSrcOptions(this.parseUsersResponse(response));
    }
}

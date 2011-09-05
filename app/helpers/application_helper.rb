# -*- coding: utf-8 -*-

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include PrototypeWindowClassHelper

  def make_blank_field_hyphen(column, blank_char=nil)
    if column.to_s.empty?
      blank_char || '-'
    else
      h column
    end
  end

  def ajax_request_function_for_field_for_users(user_select_id, division_field_id, phrase_field_id)
      javascript_tag(<<-EOS)
        function ajax_request_for_#{user_select_id}() {
          new Ajax.Request('#{users_path(:json)}',
                           {
                             method:'get',
                             asynchronous:true,
                             evalScripts:true,
                             parameters:{
                               division_id:$F('#{division_field_id}'),
                               phrase:$F('#{phrase_field_id}')
                             },
                             onComplete:function(response){
                               select_tag = $('#{user_select_id}');
                               for (var i = select_tag.options.length - 1; i >= 0; i--) {
                                 select_tag.options[i] = null;
                               }
                               var count = 0;
                               response.responseJSON.collect(function (e) {
                                 return e.user;
                               }).each(function (user) {
                                 option = new Option(user.name, user.id);
                                 // option.className = 'even';
                                 select_tag[count++] = option;
                               })
                               new Effect.Highlight('#{user_select_id}');
                             }
                           });
        }
      EOS
  end

  def field_for_users(name, options={ })
    options.symbolize_keys!
    default_options = {
    }
    unless @user.is_a?(User)
      raise new ArgumentError('@user is not defined')
    end
    options = default_options.merge(options)
    html = ''
    prefix = "field_for_users_#{name}_#{@user.id}"
    prefix_for_division_select = prefix + '_division_select'
    prefix_for_user_select = prefix + '_user_select'
    ajax_request_function = "ajax_request_for_#{prefix_for_user_select}();"
    prefix_for_phrase = prefix + '_phrase'

    html << I18n.t('affiliation') + ':'
    html << select_tag(prefix + '_division_select',
                       options_for_select(Division.all.collect { |division|
                                            [division.nested_name, division.id]
                                          },
                                          @user.divisions.primary.id),
                       :name => nil,
                       :onchange => ajax_request_function)

    html << I18n.t('freeword')  + ':'
    html << text_field_tag(prefix_for_phrase, params[:phrase], :name => nil, :onkeypress => <<-EOS)
      if (event.keyCode == Event.KEY_RETURN) {
        #{ajax_request_function}
      }
    EOS
    html << %(<span class="annotation">#{I18n.t('press_enter')}</span>)

    html << '<br />'
    html << select_tag(name.to_s,
                       options_for_select(User.scoped_by_division_full_set(@user.divisions.primary).collect { |user|
                                            [user.name, user.id]
                                          },
                                          @user.id),
                       :id => prefix_for_user_select)

    html << ajax_request_function_for_field_for_users(prefix_for_user_select,
                                                      prefix_for_division_select,
                                                      prefix_for_phrase)
  end

  def dummy_id
    1
  end

  def division_select_tag(name, division, options={ })
    division = Division.find_by_id(division) || Division.root
    select_tag(name,
               options_for_select(Division.organized.all.collect { |d|
                                    [d.nested_name, d.id]
                                  },
                                  division.id),
               options)
  end

  def init_row_span(length)
    if length.zero?
      @row_spaning_length = 1
    else
      @row_spaning_length = length.to_i
    end
  end

  def row_spannable?
    @row_spaning_length ? true : false
  end

  def row_span
    if @row_spaning_length
      row_span = @row_spaning_length
      @row_spaning_length = nil
      row_span
    end
  end

  def init_odd_or_even
    @odd = true
  end

  def odd_or_even(change=true)
    if change
      (@odd = @odd ? false : true) ? 'odd' : 'even'
    else
      @odd ? 'odd' : 'even'
    end
  end

  def selectable_points
    if defined?(@points)
      @points
    else
      @points = Point.find :all, :order => :seq
    end
  end

  def describe_points
    selectable_points.collect { |point|
      "#{point.abbrev}=#{point.name}"
    }.join('&nbsp;' * 3).html_safe
  end

  def button_tag(s, options={ })
    options.symbolize_keys!
    options.update(:type => 'submit') unless options[:type]
    options[:class] = 'button ' + options[:class].to_s
    content_tag :button, s, options
  end

  # NOTE:テキストフォームでのエンターキータイプによるサブミットを抑制
  def save_button_tag(s=I18n.t('save'), options={ })
    options[:onclick] ||= ''
    options[:onclick] << <<-EOS
      ; form.onsubmit ? form.onsubmit() : form.submit();
    EOS
    tag(:input, options.merge({ :type => 'button', :value => s}))
  end

  def icon_image_tag(source, options={ })
    options.symbolize_keys!
    defualt_options = { :border => 0}
    options = defualt_options.merge(options)
    image_tag(source, options)
  end

  def add_icon_tag(options={ })
    icon_image_tag 'add.png', options
  end

  def close_icon_tag(options={ })
    icon_image_tag 'close_hl.png', options
  end

  def delete_icon_tag(options={ })
    icon_image_tag 'delete.png', options
  end

  def edit_icon_tag(options={ })
    icon_image_tag 'edit.png', options
  end

  def check_icon_tag(options={ })
    icon_image_tag 'true.png', options
  end

  def weak_check_icon_tag(options={ })
    icon_image_tag 'weak_true.png', options
  end

  def bullet_icon_tag(options={ })
    icon_image_tag 'bullet_orange.png', options
  end

  def weak_bullet_icon_tag(options={ })
    icon_image_tag 'weak_bullet_orange.png', options
  end

  def save_icon_tag(options={ })
    icon_image_tag(File.join('web-app-theme', 'tick.png'), options)
  end

  def expand_icon_tag(options={ })
    icon_image_tag 'expand.png', options
  end

  def shrink_icon_tag(options={ })
    icon_image_tag 'shrink.png', options
  end

  def message_icon_tag(options={ })
    icon_image_tag 'message.png', options
  end

  def csv_icon_tag(options={ })
    icon_image_tag 'csv.png', options
  end

  def pdf_icon_tag(options={ })
    icon_image_tag 'pdf.png', options
  end

  def loading_icon_tag(options={ })
    options[:class] ||= ''
    options[:class] += ' loading_icon'
    icon_image_tag 'rotating_arrow.gif', options
  end

  def sanitize_to_id(name)
    name.to_s.gsub(']','').gsub(/[^-a-zA-Z0-9:.]/, "_")
  end

  def setting_modification_enabled?
    current_user.roles.admin?
  end
end

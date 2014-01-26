$(document).ready ->
  $(document).on "click", '.view-message', ->
    uid = $(@).data('uid')
    $("##{uid}").slideToggle()

  $(document).on 'click', '.view-message button', ->
    uid = $(@).parent().data('uid')
    $(@).text(get_button_text(uid))

  $('#archives-table').ready ->
    list = $("#archives-table").data("list")
    return unless list

    $.ajax
      type: "GET"
      url: "/lists/#{list}/archives.js"

  get_button_text = (uid) ->
    if $("##{uid}").is(':visible')
      "View Message"
    else
      "Hide Message"
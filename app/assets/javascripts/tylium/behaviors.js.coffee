# behaviors.js
#
# In this file we bind general-purpose jQuery plugins with the corresponding
# elements in the page in an unobtrusive way.
#
# The current list of plugins:
#   * jQuery.fileUpload  - handles attachment uploads (gem: jquery-fileupload-rails)
#   * jQuery.Textile     - handles the note editor (/vendor/)

document.addEventListener "turbolinks:load", ->
  # --------------------------------------------------- Standard jQuery plugins
  # Activate jQuery.fileUpload
  $('.jquery-upload').fileupload
    dropZone: $('#drop-zone')
    destroy: (e, data) ->
      if confirm('Are you sure?\n\nProceeding will delete this attachment from the associated node.')
        $.blueimp.fileupload.prototype.options.destroy.call(this, e, data)

    paste: (e, data)->
      $.each data.files, (index, file) ->
        filename = prompt('Please provide a filename for the pasted image', 'screenshot-XX.png') || 'unnamed.png'
        # Clone file object, edit, then reapply to the data object
        newFile = new File [file], filename, { type: file.type }
        data.files[index] = newFile

  # Initialize clipboard.js:
  clipboard = new Clipboard('.js-attachment-url-copy')

  clipboard.on 'success', (e) ->
    $btn = $(e.trigger)
    e.clearSelection()
    $btn.tooltip
      placement: 'bottom'
      title:     'Copied attachment URL to clipboard!',
      trigger:   'manual'
    $btn.tooltip('show')


  clipboard.on 'error', (e) ->
    actionKey = if e.action == 'cut' then 'X' else 'C'
    if /Mac/i.test(navigator.userAgent)
      actionMsg = 'Press ⌘-' + actionKey + ' to '+ e.action
    else
      actionMsg = 'Press Ctrl-' + actionKey + ' to ' + e.action

    $btn = $(e.trigger)

    $btn.tooltip
      placement: 'bottom'
      title:     actionMsg
      trigger:   'manual'
    $btn.tooltip('show')


  $(".attachments-box").on "mouseleave", ".js-attachment-url-copy", ->
    $this = $(this)
    $this.tooltip('hide')


  # -------------------------------------------------------- Our jQuery plugins
  # Activate jQuery.Textile
  $('.textile').textile()

  # Activate jQuery.breadCrumbs
  $('.breadcrumb').breadcrumbs
    tree: $('.main-sidebar .tree-navigation')

  # Activate jQuery.treeNav
  $('.tree-navigation').treeNav()

  # Activate jQuery.treeModal
  $('.modal-node-selection-form').treeModal()


  # ------------------------------------------------------- Bootstrap behaviors

  # Focus first input on modal window display.

  $('.modal').on 'shown.bs.modal', ->
    $(this).find('input:text:visible:first').focus()

  $('.js-try-pro').on 'click', ->
    $this   = $(this)
    term    = $this.data('term')
    $modal  = $('#try-pro')
    $iframe = $('#try-pro iframe')
    url     = $iframe.data('url')

    if $this.data('url')
      url = $this.data('url')

      title = switch term
        when 'boards' then '<span>[Dradis Pro feature]</span> Advanced boards and task assignment'
        when 'contact-support' then '<span>[Dradis Pro feature]</span> Dedicated Support team'
        when 'issuelib' then '<span>[Dradis Pro feature]</span> Integrated library of vulnerability descriptions'
        when 'projects' then '<span>[Dradis Pro feature]</span> Work with multiple projects'
        when 'remediation' then '<span>[Dradis Pro feature]</span> Integrated remediation tracker'
        when 'word-reports' then '<span>[Dradis Pro feature]</span> Custom Word reports'
        when 'excel-reports' then '<span>[Dradis Pro feature]</span> Custom Excel reports'
        when 'node-boards' then '<span>[Dradis Pro feature]</span> Node-level methodologies'
        when 'training-course' then 'Dradis Training Course'
        when 'try-pro' then 'Upgrade to Dradis Pro'

      $modal.find('[data-behavior~=modal-title]').html(title)
    else
      $modal.find('[data-behavior~=modal-title]').text('Dradis Framework editions')

    url = url + '?utm_source=ce&utm_medium=app&utm_campaign=try-pro&utm_term=' + term

    $iframe.attr('src', url)
    $('#try-pro').modal()

  # If project id is changed in project path
  if !(/^\/projects\/1(\/|$)/.test(window.location.pathname))
    $('[data-behavior~=project-teaser]').removeClass('d-none')

  if ($poller = $("#activities-poller")).length
    unless ActivitiesPoller.initialized
      ActivitiesPoller.init($poller)
      ActivitiesPoller.poll()

  # Disable form buttons after submitting them.
  $('form').submit (ev)->
    $('input[type=submit]', this).attr('disabled', 'disabled').val('Processing...')

  # Search form
  $('[data-behavior~=form-search]').hover ->
    $('[data-behavior~=search-query]').val('').focus() 

  submitSearch = ->
    if $('[data-behavior~=search-query]').val() != ''
      $('[data-behavior~=form-search]').submit()
      $('[data-behavior~=search-query]').val('Searching...') 
      return false
    else 
      $('[data-behavior~=search-query]').effect( "shake", { direction: "left", times: 2, distance: 5}, 'fast' ).focus();

  $('[data-behavior~=search-button]').on 'click', (e)->
    e.preventDefault()
    submitSearch()

  $('[data-behavior~=search-query]').on 'keypress', (e)->
    if e.which == 13
      submitSearch()

  # Collapsable div in sidebar collections
  if $('[data-behavior~=collapse-collection]').length
    $('[data-behavior~=collapse-collection]').click ->
      $this = $(this)
      $this.find('[data-behavior~=toggle-chevron]').toggleClass('fa-chevron-down fa-chevron-up')

      if $this.is('[data-behavior~=import-box]') && $($this.data('target')).innerHeight() == 0
        $($this.data('target')).find("input[type='text']:first").focus()

  # Close nav collapse menu when nav dropdown menu is opened
  $('[data-behavior~=close-collapse]').on 'click', ->
    $('[data-behavior~=navbar-collapse]').collapse 'hide'
    return

  # Toggle sidebar menu

  $sidebar = $('[data-behavior~=main-sidebar]')

  sidebarOpen = -> 
    $sidebar.removeClass('sidebar-collapsed').addClass('sidebar-expanded')
    $sidebar.attr('data-behavior', 'main-sidebar sidebar-expanded')
    $('[data-behavior~=back-fade]').removeClass('not-faded').addClass('faded')

  sidebarClose = ->
    $sidebar.removeClass('sidebar-expanded').addClass('sidebar-collapsed')
    $sidebar.attr('data-behavior', 'main-sidebar sidebar-collapsed')
    $('[data-behavior~=back-fade]').removeClass('faded').addClass('not-faded')

  $('[data-behavior~=sidebar-toggle]').on 'click', ->
    if $sidebar.is('[data-behavior~=sidebar-collapsed]')
      sidebarOpen()
    else
      if $(this).is('[data-behavior~=open-only]')
        return
      else
        sidebarClose()

  $('[data-behavior~=back-fade]').on 'click', ->
    sidebarClose()

  $('[data-behavior~=sidebar-link]').on 'click', ->
    if $sidebar.is('[data-behavior~=sidebar-expanded]')
      sidebarClose() 

  # Scroll for more indicator functionality
  if $('[data-behavior~=restrict-height').length
    checkOverflow = ->
      $('[data-behavior~=restrict-height').each ->
        if $(this).innerHeight() + 32 < $(this)[0].scrollHeight && $(this).innerHeight() > 100 # if container is > 100px and has overflowing content
          if $(this).scrollTop() + $(this).innerHeight() >= $(this)[0].scrollHeight # if already at the bottom
            return
          else
            $(this).find($('[data-behavior~=scroll-wrapper')).removeClass('hidden');
        else
          $(this).find($('[data-behavior~=scroll-wrapper')).addClass('hidden');
      return

    $('[data-behavior~=restrict-height').append('<div class="scroll-more-wrapper hidden" data-behavior="scroll-wrapper"><span class="scroll-more">Scroll for more</span><span class="gradient"></span><span class="line"></span></div>')
    checkOverflow()

    $(window).resize ->
      checkOverflow()

    $('[data-behavior~=restrict-height').on 'scroll', ->
      if $(this).scrollTop() + 64 + $(this).innerHeight() >= $(this)[0].scrollHeight
        $(this).find($('[data-behavior~=scroll-wrapper')).addClass('hidden');
      else
        $(this).find($('[data-behavior~=scroll-wrapper')).removeClass('hidden');

  # Smooth Scrolling
  $('[data-behavior~=smooth-scroll]').on 'click', ->
    target = $(this).data('target');
    $('[data-id~=' + target + ']')[0].scrollIntoView({behavior: "smooth"});

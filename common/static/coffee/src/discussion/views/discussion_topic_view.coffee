if Backbone?
  class @DiscussionTopicView extends Backbone.View
      initialize: (options) ->
          @course_settings = options.course_settings
          @topicId = options.topicId
          @mode = options.mode
          @maxNameWidth = 100

      events:
          "click .post-topic-button": "toggleTopicDropdown"
          "click .topic-menu-wrapper": "handleTopicEvent"
          "click .topic-filter-label": "ignoreClick"
          "keyup .topic-filter-input": DiscussionFilter.filterDrop

      attributes:
        "class": "post-field"

      # Because we want the behavior that when the body is clicked the menu is
      # closed, we need to ignore clicks in the search field and stop propagation.
      # Without this, clicking the search field would also close the menu.
      ignoreClick: (event) ->
          event.stopPropagation()

      render: () ->
          context = _.clone(@course_settings.attributes)
          context.topics_html = @renderCategoryMap(@course_settings.get("category_map")) if @isTabMode()
          if @isTabMode()
              # set up the topic dropdown in tab mode
              @$el.html(_.template($("#topic-template").html(), context))
              @dropdownButton = @$(".post-topic-button")
              @topicMenu      = @$(".topic-menu-wrapper")
              @selectedTopic  = @$(".js-selected-topic")
              @hideTopicDropdown()
              links = @$("a.topic-title")
              if @getTopicId()
                @setTopic(links.filter('[data-discussion-id=' + @getTopicId() + ']'))
              else
                @setTopic(links.first())
          return @$el

      renderCategoryMap: (map) ->
          category_template = _.template($("#new-post-menu-category-template").html())
          entry_template = _.template($("#new-post-menu-entry-template").html())
          html = ""
          for name in map.children
              if name of map.entries
                  entry = map.entries[name]
                  html += entry_template({text: name, id: entry.id, is_cohorted: entry.is_cohorted})
              else # subcategory
                  html += category_template({text: name, entries: @renderCategoryMap(map.subcategories[name])})
          html

      isTabMode: () ->
          return @mode is "tab"

      toggleTopicDropdown: (event) ->
          event.preventDefault()
          event.stopPropagation()
          if @menuOpen
              @hideTopicDropdown()
          else
              @showTopicDropdown()

      showTopicDropdown: () ->
          @menuOpen = true
          @dropdownButton.addClass('dropped')
          @topicMenu.show()
          $(".form-topic-drop-search-input").focus()

          $("body").bind "click", @hideTopicDropdown

          # Set here because 1) the window might get resized and things could
          # change and 2) can't set in initialize because the button is hidden
          @maxNameWidth = @dropdownButton.width() - 40

      # Need a fat arrow because hideTopicDropdown is passed as a callback to bind
      hideTopicDropdown: () =>
          @menuOpen = false
          @dropdownButton.removeClass('dropped')
          @topicMenu.hide()
          $("body").unbind "click", @hideTopicDropdown

      handleTopicEvent: (event) ->
          event.preventDefault()
          event.stopPropagation()
          @setTopic($(event.target))

      setTopic: ($target) ->
          if $target.data('discussion-id')
              @topicText  = @getFullTopicName($target)
              @topicId    = $target.data('discussion-id')
              @setSelectedTopicName(@topicText)
              if $target.data("cohorted")
                $(".js-group-select").prop("disabled", false)
              else
                $(".js-group-select").val("").prop("disabled", true)
              @hideTopicDropdown()

      getTopicId: ->
        return @topicId

      setSelectedTopicName: (text) ->
          @selectedTopic.html(@fitName(text))

      # Return full name for the `topicElement` if it is passed.
      # Otherwise, full name for the last set topic will be returned.
      getFullTopicName: (topicElement) ->
          if topicElement
            name = topicElement.html()
            topicElement.parents('.topic-submenu').each ->
                name = $(this).siblings('.topic-title').text() + ' / ' + name
            return name
          else
            return @topicText

      getNameWidth: (name) ->
          test = $("<div>")
          test.css
              "font-size": @dropdownButton.css('font-size')
              opacity: 0
              position: 'absolute'
              left: -1000
              top: -1000
          $("body").append(test)
          test.html(name)
          width = test.width()
          test.remove()
          return width

      fitName: (name) ->
          width = @getNameWidth(name)
          if width < @maxNameWidth
              return name
          path = (x.replace /^\s+|\s+$/g, "" for x in name.split("/"))
          while path.length > 1
              path.shift()
              partialName = gettext("…") + " / " + path.join(" / ")
              if  @getNameWidth(partialName) < @maxNameWidth
                  return partialName

          rawName = path[0]

          name = gettext("…") + " / " + rawName

          while @getNameWidth(name) > @maxNameWidth
              rawName = rawName[0...rawName.length-1]
              name =  gettext("…") + " / " + rawName + " " + gettext("…")

          return name

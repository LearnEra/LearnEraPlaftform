# -*- coding: utf-8 -*-
describe "NewPostView", ->
    beforeEach ->
        DiscussionSpecHelper.setUpGlobals()
        DiscussionSpecHelper.setUnderscoreFixtures()
        window.$$course_id = "edX/999/test"
        spyOn(DiscussionUtil, "makeWmdEditor")
        @discussion = new Discussion([], {pages: 1})

    describe "cohort selector", ->
      beforeEach ->
        @course_settings = new DiscussionCourseSettings({
          "category_map": {
            "children": ["Topic"],
            "entries": {"Topic": {"is_cohorted": true, "id": "topic"}}
          },
          "allow_anonymous": false,
          "allow_anonymous_to_peers": false,
          "is_cohorted": true,
          "cohorts": [
            {"id": 1, "name": "Cohort1"},
            {"id": 2, "name": "Cohort2"}
          ]
        })
        @view = new NewPostView(
          el: $("#fixture-element"),
          collection: @discussion,
          course_settings: @course_settings,
          mode: "tab"
        )

      expectCohortSelectorVisible = (view, visible) ->
        expect(view.$(".js-group-select").is(":visible")).toEqual(visible)

      it "is not visible to students", ->
        @view.render()
        expectCohortSelectorVisible(@view, false)

      it "allows moderators to select visibility", ->
        DiscussionSpecHelper.makeModerator()
        @view.render()
        expectCohortSelectorVisible(@view, true)
        expect(@view.$(".js-group-select").prop("disabled")).toEqual(false)

        expectedGroupId = null
        DiscussionSpecHelper.makeAjaxSpy(
          (params) -> expect(params.data.group_id).toEqual(expectedGroupId)
        )

        _.each(
          ["1", "2", ""],
          (groupIdStr) =>
            expectedGroupId = groupIdStr
            @view.$(".js-group-select").val(groupIdStr)
            @view.$(".js-post-title").val("dummy title")
            @view.$(".js-post-body textarea").val("dummy body")
            @view.$(".forum-new-post-form").submit()
            expect($.ajax).toHaveBeenCalled()
            $.ajax.reset()
        )

    it "posts to the correct URL", ->
      topicId = "test_topic"
      spyOn($, "ajax").andCallFake(
        (params) ->
          expect(params.url.path()).toEqual(DiscussionUtil.urlFor("create_thread", topicId))
          {always: ->}
      )
      view = new NewPostView(
        el: $("#fixture-element"),
        collection: @discussion,
        course_settings: new DiscussionCourseSettings({
          allow_anonymous: false,
          allow_anonymous_to_peers: false
        }),
        mode: "inline",
        topicId: topicId
      )
      view.render()
      view.$(".forum-new-post-form").submit()
      expect($.ajax).toHaveBeenCalled()

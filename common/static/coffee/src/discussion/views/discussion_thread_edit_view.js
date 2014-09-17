(function(Backbone) {
    'use strict';
    if (Backbone) {
        this.DiscussionThreadEditView = Backbone.View.extend({
            tagName: 'form',
            events: {
                'submit': 'updateHandler',
                'click .post-cancel': 'cancelHandler'
            },

            attributes: {
                'class': 'discussion-post edit-post-form'
            },

            initialize: function(options) {
                this.container = options.container || $('.thread-content-wrapper');
                this.mode = options.mode || 'inline';
                this.course_settings = options.course_settings;
                this.topicId = options.topicId;
                this.topic = new DiscussionTopicView({
                    topicId: this.topicId,
                    course_settings: this.course_settings,
                    mode: this.mode
                });
                _.bindAll(this);
                return this;
            },

            render: function() {
                this.template = _.template($('#thread-edit-template').html());
                this.$el.html(this.template(this.model.toJSON())).appendTo(this.container);
                this.submitBtn = this.$('.post-update');
                this.addField(this.topic.render());
                DiscussionUtil.makeWmdEditor(this.$el, $.proxy(this.$, this), 'edit-post-body');
                return this;
            },

            addField: function(fieldView) {
                this.$('.forum-edit-post-panel').append(fieldView);
                return this;
            },

            save: function() {
                var title = this.$('.edit-post-title').val(),
                    body = this.$('.edit-post-body textarea').val(),
                    commentableId = this.topic.getTopicId();

                return DiscussionUtil.safeAjax({
                    $elem: this.submitBtn,
                    $loading: this.submitBtn,
                    url: DiscussionUtil.urlFor('update_thread', this.model.id),
                    type: 'POST',
                    dataType: 'json',
                    async: false, // @TODO when the rest of the stuff below is made to work properly..
                    data: {
                        title: title,
                        body: body,
                        commentable_id: commentableId
                    },
                    error: DiscussionUtil.formErrorHandler(this.$('.post-errors')),
                    success: function() {
                        // @TODO: Move this out of the callback, this makes it feel sluggish
                        this.$('.edit-post-title').val('').attr('prev-text', '');
                        this.$('.edit-post-body textarea').val('').attr('prev-text', '');
                        this.$('.wmd-preview p').html('');
                        this.model.set({
                            title: title,
                            body: body,
                            commentable_id: commentableId,
                            courseware_title: this.topic.getFullTopicName()
                        });
                        this.model.unset('abbreviatedBody');
                        this.trigger('thread:updated');
                    }.bind(this)
                });
            },

            updateHandler: function(event) {
                event.preventDefault();
                this.trigger('thread:update', event);
                this.save();
                return this;
            },

            cancelHandler: function(event) {
                event.preventDefault();
                this.trigger("thread:cancel_edit", event);
                this.remove();
                return this;
            }
        });
    }
}).call(this, Backbone);

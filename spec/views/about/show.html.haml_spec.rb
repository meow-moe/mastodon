# frozen_string_literal: true

require 'rails_helper'

describe 'about/show.html.haml', without_verify_partial_doubles: true do
  around do |example|
    activity_api_enabled = Setting.activity_api_enabled
    example.run
    Setting.activity_api_enabled = activity_api_enabled
  end

  before do
    allow(view).to receive(:site_hostname).and_return('example.com')
    allow(view).to receive(:site_title).and_return('example site')
    allow(view).to receive(:new_user).and_return(User.new)
    allow(view).to receive(:use_seamless_external_login?).and_return(false)

  it 'has valid open graph tags' do
    instance_presenter = double(
      :instance_presenter,
      site_title: 'something',
      site_short_description: 'something',
      site_description: 'something',
      version_number: '1.0',
      source_url: 'https://github.com/tootsuite/mastodon',
      open_registrations: false,
      thumbnail: nil,
      hero: nil,
      mascot: nil,
      user_count: 420,
      status_count: 69,
      active_user_count: 420,
      contact_account: nil,
      sample_accounts: []
    )

    assign(:instance_presenter, instance_presenter)
  end

  it 'has valid open graph tags' do
    render

    header_tags = view.content_for(:header_tags)

    expect(header_tags).to match(%r{<meta content=".+" property="og:title" />})
    expect(header_tags).to match(%r{<meta content="website" property="og:type" />})
    expect(header_tags).to match(%r{<meta content=".+" property="og:image" />})
    expect(header_tags).to match(%r{<meta content="http://.+" property="og:url" />})
  end

  context 'when activity api is enabled' do
    before do
      Setting.activity_api_enabled = true
    end

    it 'displays aggregate statistics about user activity' do
      render
      expect(rendered).to have_css('.hero-widget__counters__wrapper .hero-widget__counter:nth-child(1) strong', text: '420')
      expect(rendered).to have_css('.hero-widget__counters__wrapper .hero-widget__counter:nth-child(1) span', text: 'users')

      expect(rendered).to have_css('.hero-widget__counters__wrapper .hero-widget__counter:nth-child(2) strong', text: '420')
      expect(rendered).to have_css('.hero-widget__counters__wrapper .hero-widget__counter:nth-child(2) span', text: 'active')
    end
  end

  context 'when activity api is disabled' do
    before do
      Setting.activity_api_enabled = false
    end

    it 'doesn\'t display aggregate statistics about user activity' do
      render
      expect(rendered).to_not have_css('.hero-widget__counters__wrapper')
    end
  end  
end

namespace :world_cup_2018 do
  desc 'Move kickoff times relatively to current time'
  task move_kickoff_times: :environment do |t, args|
    # move to the tenth game
    raise 'Not allowed to run in production' if Rails.env.production?

    matches_count = Match.count
    match_number = args.to_a.first.to_i
    raise "Given match number '#{match_number}' is not allowed" if match_number > matches_count

    match = Match.order(:kickoff_at).limit(1).offset(match_number-1).first
    delta = (match.kickoff_at.to_date - Time.zone.today).to_i

    Match.find_each do |match|
      new_match_kickoff_time = (match.kickoff_at - delta.days)
      match.update(kickoff_at: new_match_kickoff_time)
    end
  end
end

require "../../spec_helper"

describe "Chizge::Algorithms::Coloring" do
  it "colorize_graph_welsh" do
    g = Chizge::Graph.new

    # How many sessions do we need for exams?
    # Which lectures can not be in the same sessions?
    student_list_with_lecture = [
      ["Lecture 1", "Lecture 2", "Lecture 5"],
      ["Lecture 1", "Lecture 3", "Lecture 5"],
      ["Lecture 3", "Lecture 4", "Lecture 6"],
      ["Lecture 4", "Lecture 5", "Lecture 6"],
    ]

    student_list_with_lecture.each do |r|
      g.add_complete(r)
    end

    Chizge::Algorithms::Coloring.welsh_powell(g).should eq({
      "Lecture 5" => "#1abc9c", "Lecture 3" => "#f1c40f",
      "Lecture 2" => "#f1c40f", "Lecture 1" => "#2ecc71",
      "Lecture 4" => "#2ecc71", "Lecture 6" => "#e67e22",
    })
  end
end

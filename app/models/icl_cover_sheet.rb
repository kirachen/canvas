require "prawn"
require "barby"
require "barby/barcode/code_128"
require 'barby/outputter/prawn_outputter'
require "date"
require "time"

class IclCoverSheet

  include Prawn::View

  def initialize(student_name, student_id, student_class, lecturer_name, lecturer_id, course_title, course_id, exercise_title, exercise_id, issued_date, due_date, assessment_type, group_members, group_id)
    @student_name = student_name
    @student_id = student_id
    @student_class = student_class
    @lecturer_name = lecturer_name
    @lecturer_id = lecturer_id
    @course_title = course_title
    @course_id = course_id
    @exercise_title = exercise_title
    @exercise_id = exercise_id
    @issued_date = issued_date
    @due_date = due_date
    @assessment_type = assessment_type
    @group_members = group_members
    @group_id = group_id
    @year, @next_year = get_academic_year(Date.today)
    @rubric_line_y = 350
    font "Times-Roman"
  end
  
  def generate_cover_sheet
    print_student
    move_down 60
    print_department
    print_logo
    move_down 27
    print_exercise
    move_down 20
    print_declaration
    print_rubric
    print_sort_info
  end

  def render_to(file_path)
    render_file file_path
  end

  def print_logo
    image "app/icl_images/imperial_logo.jpg", :width => 150, :height => 42, :position => :left, :at => [0, 660]
  end
   
  def print_department
    text "Department of Computing", :align => :right, :size => 20
    move_down 4
    text "Academic Year " + @year + "-" + @next_year, :align => :right, :size => 15
  end

  def print_student
    text_box @student_name.upcase + " (" + @student_id + ")", :align => :center, :size => 25, :at => [0, 710], :width => 540, :height => 100
  end

  def print_exercise
    text "Exercise Information", :align => :center, :size => 20
    bounding_box([0, 551], :width => 70, :height => 50) do
      text "Course:", :style => :bold, :align => :right, :size => 15
      text "FAO:", :style => :bold, :align => :right, :size => 15
      text "Exercise:", :style => :bold, :align => :right, :size => 15
    end
    bounding_box([75, 550], :width => 190, :height => 50) do
      text @course_title, :style => :bold, :align => :left, :size => 15
      text @lecturer_name, :align => :left, :size => 15
      text @exercise_title, :align => :left, :size => 15
    end
    bounding_box([285, 551], :width => 80, :height => 50) do
      text "Issued:", :style => :bold, :align => :right, :size => 15
      text "Status:", :style => :bold, :align => :right, :size => 15
      text "Assessment:", :style => :bold, :align => :right, :size => 15
    end
    onTime = false
    if (Time.now <=> @due_date) <= 0
      onTime = true
    end
    bounding_box([370, 550], :width => 180, :height => 50) do
      text @issued_date.strftime("%a %b %d %Y"), :size => 15, :align => :left
      if onTime
        text "On time", :size => 15, :align => :left
      else
        text "Late", :size => 15, :align => :left, :color => "DC143C"
      end
      text @assessment_type, :size => 15, :align => :left
    end
  end

  def print_declaration
    text "Student Declaration", :align => :center, :size => 20
    move_down(15)
    text "I declare that this final submitted version is my unaided work.", :align => :center, :size => 15
    move_down(30)
    bounding_box([20, 410], :width => 270, :height => 50) do
      move_down(20)
      text "Signature:", :size => 15
    end
    line [85, 380], [280, 380]
    bounding_box([290, 410], :width => 270, :height => 50) do
      move_down(20)
      text "Date:", :indent_paragraphs => 20, :size => 15
    end
    line [350, 380], [520, 380]
    stroke
  end

  def print_rubric
    print_rubric_for_student(@student_name, @student_id, @student_class)
    @group_members.each do |student|
      print_rubric_for_student(student["name"], student["id"], student["class"])
    end
  end 
  
  def print_rubric_for_student(student_name, student_id, student_class)
    row_height = 25
    bounding_box([20, @rubric_line_y], :width => 150, :height => row_height) do
      text_box student_name, :align => :center, :valign => :center, :width => 150, :height => 30, :overflow => :expand
      stroke_bounds
    end
    bounding_box([170, @rubric_line_y], :width => 60, :height => row_height) do
      text_box student_id, :align => :center, :valign => :center, :width => 60, :height => 30, :overflow => :expand
      stroke_bounds
    end
    bounding_box([230, @rubric_line_y], :width => 40, :height => row_height) do
      text_box student_class, :align => :center, :valign => :center, :width => 40, :height => 30, :overflow => :expand
      stroke_bounds
    end
    divider = "      "
    bounding_box([270, @rubric_line_y], :width => 250, :height => row_height) do
      formatted_text [{ :text => "A*" + divider + "A+" + divider + "A" + divider + "B" + divider + "C" + divider, :color => "0000FF"}, { :text => "D" + divider, :color => "FF00FF"}, { :text => "E" + divider + "F", :color => "DC143C"}], :align => :center, :valign => :center
      stroke_bounds
    end
    @rubric_line_y = @rubric_line_y - row_height
  end
  
  def print_sort_info
    divider = "   "
    bounding_box([0, 70], :width => 540, :height => 30) do
      #move_down(10)
      text_box @course_id + divider + @lecturer_id + divider + @exercise_id, :size =>18, :align => :right, :valign => :center, :overflow => :shrink_to_fit
    end
    bounding_box([0, 40], :width => 540, :height => 30) do
      text_box @student_class + divider + @student_id + divider, :size => 18, :align => :right, :valign => :center, :overflow => :shrink_to_fit
    end
    barcode_string = @student_id + "exe" + @exercise_id + "grp" + @group_id.to_s
    bounding_box([0, 60], :width => 540, :height => 55) do
      barcode_pos = {:x => 10, :y => 10, :height => 55}
      barcode = Barby::Code128B.new barcode_string
      barcode.annotate_pdf(self, barcode_pos)
    end
    bounding_box([20, 10], :width => 540, :height => 12) do
      text_box barcode_string, :size => 12, :align => :left
    end
  end

  def get_academic_year(today)
    term_start_date = Date.new(today.year,10,1)
    current_year = nil
    next_year = nil
    # If it is current academic year
    if (today <=> term_start_date) == -1
      current_year = term_start_date.prev_year
      next_year = term_start_date
      # If it is new academic year
    elsif (today <=> term_start_date) >= 0
      current_year = term_start_date
      next_year = term_start_date.next_year
    end
    return current_year.strftime("%Y"), next_year.strftime("%Y")
  end
end

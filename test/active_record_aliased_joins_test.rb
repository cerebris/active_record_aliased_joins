# frozen_string_literal: true

require 'test_helper'

class ActiveRecordAliasedJoinsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ActiveRecordAliasedJoins::VERSION
  end

  def test_it_can_alias_has_many
    records = Post.joins_with_alias(:comments, :jr_post_comments)
    sql = records.to_sql
    assert_equal 'SELECT "posts".* FROM "posts" ' \
                 'INNER JOIN "comments" "jr_post_comments" ON "posts"."id" = "jr_post_comments"."post_id"',
                 sql
  end

  def test_it_can_alias_has_many_outer
    records = Post.left_joins_with_alias(:comments, :jr_post_comments)
    sql = records.to_sql
    assert_equal 'SELECT "posts".* FROM "posts" ' \
                 'LEFT OUTER JOIN "comments" "jr_post_comments" ON "posts"."id" = "jr_post_comments"."post_id"',
                 sql
  end

  def test_it_can_alias_has_many_and_support_additional_join
    records = Post.joins_with_alias(:comments, :jr_post_comments).joins(author: :comments)
    sql = records.to_sql
    assert_equal 'SELECT "posts".* FROM "posts" ' \
                 'INNER JOIN "comments" "jr_post_comments" ON "posts"."id" = "jr_post_comments"."post_id" ' \
                 'INNER JOIN "people" ON "people"."id" = "posts"."author_id" ' \
                 'INNER JOIN "comments" ON "comments"."author_id" = "people"."id"',
                 sql
  end

  def test_it_can_alias_has_many_and_support_additional_join_outer
    records = Post.left_joins_with_alias(:comments, :jr_post_comments).joins(author: :comments)
    sql = records.to_sql
    assert_equal 'SELECT "posts".* FROM "posts" ' \
                 'LEFT OUTER JOIN "comments" "jr_post_comments" ON "posts"."id" = "jr_post_comments"."post_id" ' \
                 'INNER JOIN "people" ON "people"."id" = "posts"."author_id" ' \
                 'INNER JOIN "comments" ON "comments"."author_id" = "people"."id"',
                 sql
  end

  def test_it_can_alias_has_many_through
    records = Physician.joins_with_alias(:patients, :jr_patients)

    sql = records.to_sql
    assert_equal 'SELECT "physicians".* FROM "physicians" ' \
                 'INNER JOIN "appointments" ON "physicians"."id" = "appointments"."physician_id" ' \
                 'INNER JOIN "patients" "jr_patients" ON "appointments"."patient_id" = "jr_patients"."id"',
                 sql
  end

  def test_it_can_alias_has_many_through_outer
    records = Physician.left_joins_with_alias(:patients, :jr_patients)

    sql = records.to_sql
    assert_equal 'SELECT "physicians".* FROM "physicians" ' \
                 'LEFT OUTER JOIN "appointments" ON "physicians"."id" = "appointments"."physician_id" ' \
                 'LEFT OUTER JOIN "patients" "jr_patients" ON "appointments"."patient_id" = "jr_patients"."id"',
                 sql
  end

  def test_it_can_alias_nested_has_many_through
    skip
    records = Physician.joins_with_alias(:towns, :jr_patient_towns)

    sql = records.to_sql
    assert_equal 'SELECT "physicians".* FROM "physicians" ' \
                 'INNER JOIN "appointments" ON "physicians"."id" = "appointments"."physician_id" ' \
                 'INNER JOIN "patients" ON "appointments"."patient_id" = "jr_patients"."id"' \
                 'INNER JOIN "towns" "jr_patient_towns" ON "patients"."town_id" = "jr_patient_towns"."id"',
                 sql
  end

  def test_it_can_alias_belongs_to
    records = Post.joins_with_alias(:author, :jr_post_author)
    sql = records.to_sql
    assert_equal 'SELECT "posts".* FROM "posts" ' \
                 'INNER JOIN "people" "jr_post_author" ON "posts"."author_id" = "jr_post_author"."id"',
                 sql
  end

  def test_it_can_alias_belongs_to_outer
    records = Post.left_joins_with_alias(:author, :jr_post_author)
    sql = records.to_sql
    assert_equal 'SELECT "posts".* FROM "posts" ' \
                 'LEFT OUTER JOIN "people" "jr_post_author" ON "posts"."author_id" = "jr_post_author"."id"',
                 sql
  end

  def test_it_can_alias_has_one
    records = Person.joins_with_alias(:author_detail, :ad)
    sql = records.to_sql
    assert_equal 'SELECT "people".* FROM "people" INNER JOIN "author_details" "ad" ON "people"."id" = "ad"."person_id"',
                 sql
  end

  def test_it_can_alias_has_one_outer
    records = Person.left_joins_with_alias(:author_detail, :ad)
    sql = records.to_sql
    assert_equal 'SELECT "people".* FROM "people" ' \
                 'LEFT OUTER JOIN "author_details" "ad" ON "people"."id" = "ad"."person_id"',
                 sql
  end

  def test_it_can_alias_has_and_belongs_to_many
    records = Assembly.joins_with_alias(:parts, :jr_parts)

    sql = records.to_sql

    assert_equal 'SELECT "assemblies".* FROM "assemblies" ' \
                 'INNER JOIN "assemblies_parts" ON "assemblies"."id" = "assemblies_parts"."assembly_id" ' \
                 'INNER JOIN "parts" "jr_parts" ON "assemblies_parts"."part_id" = "jr_parts"."id"',
                 sql
  end

  def test_it_can_alias_has_and_belongs_to_many_outer
    records = Assembly.left_joins_with_alias(:parts, :jr_parts)

    sql = records.to_sql

    assert_equal 'SELECT "assemblies".* FROM "assemblies" ' \
                 'LEFT OUTER JOIN "assemblies_parts" ON "assemblies"."id" = "assemblies_parts"."assembly_id" ' \
                 'LEFT OUTER JOIN "parts" "jr_parts" ON "assemblies_parts"."part_id" = "jr_parts"."id"',
                 sql
  end

  def test_it_raises_an_error_with_an_unsupported_table
    assert_raises(ActiveRecord::AssociationNotFoundError) do |_e|
      Assembly.joins_with_alias(:foo, :foo_alias)
    end
  end
end

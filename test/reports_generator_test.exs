defmodule ReportsGeneratorTest do
  use ExUnit.Case

  alias ReportsGenerator.Support.ReportFixture

  @file_name "report.csv"

  describe "build/1" do
    test "When passing file name return a report" do
      response = ReportsGenerator.build(@file_name)

      assert response == ReportFixture.build()
    end

    test "When no filename was given, returns an error" do
      response = ReportsGenerator.build()

      assert response == {:error, "Insira o nome de um arquivo"}
    end
  end
end

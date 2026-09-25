# Builds cdclint from the tagged source, the way homebrew/core would. The
# cask beside it (Casks/cdclint.rb) installs the release binary instead;
# `brew install --cask avison9/tap/cdclint` picks that one. cdclint's
# release workflow rewrites `url` and `sha256` on every tag; the rest is
# by hand, and is the file that goes to homebrew/core once the project
# clears its notability bar.
class Cdclint < Formula
  desc "Lint the contract between a database, a Debezium connector and a sink"
  homepage "https://github.com/avison9/cdclint"
  url "https://github.com/avison9/cdclint/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "62bebbf159beba145f13808d16bec80425f2c3dfb864f010adf5913d0eccb7f8"
  license "Apache-2.0"
  head "https://github.com/avison9/cdclint.git", branch: "main"

  depends_on "go" => :build

  def install
    # std_go_args strips symbols like the release build; --version prints the tag.
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}"), "./cmd/cdclint"
  end

  test do
    assert_match "cdclint #{version}", shell_output("#{bin}/cdclint --version")

    # The incident the tool exists for, reduced to three files: a sink
    # reads a column the connector's include list leaves out.
    (testpath/"migrations/0001_reports.sql").write <<~SQL
      CREATE TABLE reports (
          id       UUID PRIMARY KEY,
          category TEXT NOT NULL
      );
    SQL
    (testpath/"connector.json").write <<~JSON
      {
        "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
        "topic.prefix": "rr",
        "table.include.list": "public.reports",
        "column.include.list": "public.reports\\\\.(id)"
      }
    JSON
    (testpath/"sink/0001_reports.sql").write <<~SQL
      CREATE TABLE kafka_reports (`id` String, `category` String)
      ENGINE = Kafka SETTINGS kafka_topic_list = 'rr.public.reports', kafka_format = 'JSONEachRow';
    SQL
    output = shell_output(
      "#{bin}/cdclint --migrations #{testpath}/migrations --connector #{testpath}/connector.json " \
      "--sink #{testpath}/sink", 1
    )
    assert_match "sink-column-not-captured", output
    assert_match "public.reports.category", output
  end
end

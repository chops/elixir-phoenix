defmodule LabsJidoAgent.Schemas do
  @moduledoc """
  Ecto schemas for structured LLM responses.

  These schemas define the expected structure of LLM outputs,
  enabling validation and type safety via Instructor.
  """

  defmodule CodeIssue do
    @moduledoc "Represents a code quality issue"
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field(:type, Ecto.Enum, values: [:quality, :performance, :idioms, :security])
      field(:severity, Ecto.Enum, values: [:critical, :high, :medium, :low])
      field(:line, :integer)
      field(:message, :string)
      field(:suggestion, :string)
    end

    def changeset(issue, attrs) do
      issue
      |> cast(attrs, [:type, :severity, :line, :message, :suggestion])
      |> validate_required([:type, :severity, :message, :suggestion])
    end
  end

  defmodule CodeReviewResponse do
    @moduledoc "Structured code review response from LLM"
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field(:score, :integer)
      field(:summary, :string)
      embeds_many(:issues, CodeIssue)
      field(:suggestions, {:array, :string})
      field(:resources, {:array, :string})
    end

    def changeset(review, attrs) do
      review
      |> cast(attrs, [:score, :summary, :suggestions, :resources])
      |> cast_embed(:issues)
      |> validate_required([:score, :summary])
      |> validate_number(:score, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    end
  end

  defmodule StudyResponse do
    @moduledoc "Structured study/Q&A response from LLM"
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field(:answer, :string)
      field(:concepts, {:array, :string})
      field(:resources, {:array, :string})
      field(:follow_ups, {:array, :string})
    end

    def changeset(response, attrs) do
      response
      |> cast(attrs, [:answer, :concepts, :resources, :follow_ups])
      |> validate_required([:answer])
    end
  end

  defmodule ProgressRecommendation do
    @moduledoc "A single progress recommendation"
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field(:priority, Ecto.Enum, values: [:critical, :high, :medium, :low])
      field(:type, Ecto.Enum,
        values: [:progress, :review, :encouragement, :start, :challenge]
      )

      field(:message, :string)
      field(:action, :string)
    end

    def changeset(rec, attrs) do
      rec
      |> cast(attrs, [:priority, :type, :message, :action])
      |> validate_required([:priority, :type, :message, :action])
    end
  end

  defmodule ProgressAnalysis do
    @moduledoc "Structured progress coaching response from LLM"
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      embeds_many(:recommendations, ProgressRecommendation)
      field(:strengths, {:array, :string})
      field(:challenges, {:array, :string})
      field(:next_phase_suggestion, :string)
    end

    def changeset(analysis, attrs) do
      analysis
      |> cast(attrs, [:strengths, :challenges, :next_phase_suggestion])
      |> cast_embed(:recommendations)
      |> validate_required([:recommendations])
    end
  end
end

{ pkgs, lib, config, ... }: {
  # Phoenix development environment with devenv

  packages = with pkgs; [
    # Elixir & Erlang (using beam packages for compatibility)
    beam.packages.erlang_27.elixir
    beam.packages.erlang_27.erlang

    # Language server for Emacs LSP
    elixir-ls

    # Livebook for interactive notebooks
    beam.packages.erlang_27.livebook

    # Node.js for Phoenix assets
    nodejs

    # File watching (for Phoenix live reload on Linux)
    inotify-tools

    # Optional: Uncomment as needed
    # imagemagick  # Image processing
  ];

  # PostgreSQL service
  services.postgres = {
    enable = true;
    initialDatabases = [{ name = "dev"; }];
    listen_addresses = "127.0.0.1";
  };

  # Redis service (for Phoenix PubSub, caching)
  services.redis = {
    enable = true;
  };

  # Mailpit service (email testing)
  services.mailpit = {
    enable = true;
  };

  # Optional: MinIO for S3-compatible local storage
  # services.minio = {
  #   enable = true;
  # };

  # Environment variables
  env = {
    MIX_ENV = "dev";
  };

  # Startup processes
  processes = {
    phoenix.exec = "mix phx.server";
  };

  # Shell hooks
  enterShell = ''
    echo "⚗️  Phoenix development environment loaded"
    echo ""
    echo "📦 Elixir: $(elixir --version | head -1)"
    echo "📦 Erlang: $(erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell)"
    echo "📦 Node.js: $(node --version)"
    echo ""
    echo "🗄️  PostgreSQL running on localhost:5432"
    echo "🔴 Redis running on localhost:6379"
    echo "📧 Mailpit UI: http://localhost:8025"
    echo ""
    echo "💡 Quick start:"
    echo "   mix phx.new myapp     # Create a new Phoenix app"
    echo "   mix ecto.create       # Create database"
    echo "   mix ecto.migrate      # Run migrations"
    echo "   devenv up             # Start Phoenix server"
    echo ""
  '';
}

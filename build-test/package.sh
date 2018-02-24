#!/bin/bash

make clean
test -d package-test || mkdir package-test
rm -rf package-test/*

mkdir package-test/myhtmlex-local
mix hex.build
mv myhtmlex-*.tar package-test/myhtmlex-local/
cd package-test/myhtmlex-local
tar -xf *.tar
tar -xzf *.tar.gz

cd ..
rm -rf foo
mkdir foo
cd foo
cat > mix.exs <<EOF
defmodule Foo.MixProject do
  use Mix.Project

  def project() do
    [
      app: :foo,
      version: "1.0.0",
      package: [
        links: %{},
        licenses: ["Apache 2.0"],
        description: "test",
        maintainers: ["me"]
      ],
      deps: deps()
    ]
  end

  defp deps do
    [
      {:myhtmlex, path: "../myhtmlex-local"}
    ]
  end
end
EOF

mix deps.get
mix compile

mix run -e 'IO.inspect {"html", [], [{"head", [], []}, {"body", [], ["foo"]}]} = Myhtmlex.decode("foo")'

# switch Nif operation
sed -i -e 's/^.*myhtmlex-local.*$/      {:myhtmlex, path: "..\/myhtmlex-local", runtime: false}/' mix.exs

mix compile
mix run -e 'IO.inspect {"html", [], [{"head", [], []}, {"body", [], ["foo"]}]} = Myhtmlex.decode("foo")'

echo "ok"
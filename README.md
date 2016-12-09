# custom-liquid-inheritance

Some magic to let you `extends`ify, `block`ify and `{{block.super}}`ify your liquid templates, have fun :)

## About this wheel

I, indeed, should give my special thanks to the two authors who have already
implemented the inheritance system yet:

https://github.com/locomotivecms/liquid-template-inheritance

https://github.com/danwrong/liquid-inheritance

and countless links and resources on google and stackoverflow that have helped me a lot on this.

I decided to make yet another wheel which maybe seems somewhat toyish since I'm not an experienced Ruby developer but just on my way learning it because I've tried the two repos for two weeks but still can't make it work, which indeed frustrated me a bit, I cancelled my thoughts to fork and modify, and then, there comes a new wheel :D

## How to use it

1. git clone this_repo

2. cd this_repo

3. gem build custom-liquid-inheritance.gemspec

4. gem install --local custom-liquid-inheritance-0.0.1.gem
  
  `--local` is a must-have otherwise online gems will be checked first.

5. in your Sinatra based App puts:

  ```
  helpers ::CustomLiquidInheritance::RenderHelper
  ```

6. in your Sinatra based Controller:

  ```
  render_liquid('pages/home', "aaa" => 999, "bbb"=>888)
  ```

You probably need to set Liquid filesystem pointing to your root liquid template folder in case it throws errors like "xxx doesn't support including...".
